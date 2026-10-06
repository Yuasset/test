-- Optional conveniences. All settings are opt-in and stored with QTR_PS.
local L = WoWTR_Localization
local frame = CreateFrame("Frame")
local merchant, busy, pendingScan = false, false, false
local blocked = {}
local failedContainers = {}
local keys = { "qolCombatLog", "qolSellJunk", "qolRepair", "qolContainers", "qolUnwrapCollections" }

-- Classic clients may expose some bag/item functions only as globals.
local GetBagSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local UseBagItem = C_Container and C_Container.UseContainerItem or UseContainerItem
local GetBagCooldown = C_Container and C_Container.GetContainerItemCooldown or GetContainerItemCooldown
local GetItemDetails = C_Item and C_Item.GetItemInfo or GetItemInfo

local function GetBagItem(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        return C_Container.GetContainerItemInfo(bag, slot)
    end
    if not GetContainerItemInfo then return end
    local icon, count, locked, quality, readable, loot, link, filtered, noValue, itemID = GetContainerItemInfo(bag, slot)
    if not icon then return end
    itemID = itemID or (GetContainerItemID and GetContainerItemID(bag, slot))
        or (link and tonumber(link:match("item:(%d+)")))
    return { iconFileID = icon, stackCount = count, isLocked = locked, quality = quality,
        isReadable = readable, hasLoot = loot, hyperlink = link, isFiltered = filtered,
        hasNoValue = noValue, itemID = itemID }
end

local function CollectionSupport()
    local mounts, pets, toys = C_MountJournal, C_PetJournal, C_ToyBoxInfo
    return mounts and mounts.GetMountIDs and mounts.NeedsFanfare and mounts.ClearFanfare,
        pets and pets.GetOwnedPetIDs and pets.PetNeedsFanfare and pets.ClearFanfare,
        toys and toys.NeedsFanfare and toys.ClearFanfare
end

local function Supported(key)
    if key == "qolCombatLog" then return LoggingCombat and GetInstanceInfo end
    if key == "qolRepair" then
        return CanMerchantRepair and GetRepairAllCost and RepairAllItems and GetMoney
    end
    if key == "qolUnwrapCollections" then
        local mounts, pets, toys = CollectionSupport()
        return mounts or pets or toys
    end
    local bags = GetBagSlots and UseBagItem
        and ((C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo)
    if key == "qolSellJunk" then return bags and GetItemDetails and GetMoney end
    if key == "qolContainers" then return bags and GetBagCooldown end
    return true
end

local function Enabled(key)
    return QTR_PS and QTR_PS[key] == "1" and not not Supported(key)
end


local collectionPending, collectionBusy = false, false
local pendingToys = {}
local function QueueCollectionUnwrap()
    if collectionPending or collectionBusy or not Enabled("qolUnwrapCollections") then return end
    collectionPending = true
    C_Timer.After(0.2, function()
        collectionPending = false
        if not Enabled("qolUnwrapCollections") then pendingToys = {}; return end
        if InCombatLockdown() then return end
        collectionBusy = true
        local mounts, pets, toys = C_MountJournal, C_PetJournal, C_ToyBoxInfo
        if mounts and mounts.GetMountIDs and mounts.NeedsFanfare and mounts.ClearFanfare then
            for _, id in ipairs(mounts.GetMountIDs() or {}) do
                if mounts.NeedsFanfare(id) then mounts.ClearFanfare(id) end
            end
        end
        if pets and pets.GetOwnedPetIDs and pets.PetNeedsFanfare and pets.ClearFanfare then
            for _, id in ipairs(pets.GetOwnedPetIDs() or {}) do
                if pets.PetNeedsFanfare(id) then pets.ClearFanfare(id) end
            end
        end
        if toys and toys.NeedsFanfare and toys.ClearFanfare then
            -- Event IDs include new toys hidden by the player's journal filters.
            if C_ToyBox and C_ToyBox.GetNumFilteredToys and C_ToyBox.GetToyFromIndex then
                for index = 1, C_ToyBox.GetNumFilteredToys() do
                    local id = C_ToyBox.GetToyFromIndex(index)
                    if id then pendingToys[id] = true end
                end
            end
            for id in pairs(ToyBox and ToyBox.fanfareToys or {}) do pendingToys[id] = true end
            for id in pairs(pendingToys) do
                if toys.NeedsFanfare(id) then
                    if ToyBox and ToyBox.fanfareToys then ToyBox.fanfareToys[id] = nil end
                    toys.ClearFanfare(id)
                end
            end
        end
        pendingToys = {}
        collectionBusy = false
    end)
end

-- Independent of the container APIs so collection support can vary by client.
local collectionFrame = CreateFrame("Frame")
collectionFrame:RegisterEvent("PLAYER_LOGIN")
collectionFrame:SetScript("OnEvent", function(self, event, id)
    if event == "PLAYER_LOGIN" then
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        local mounts, pets, toys = CollectionSupport()
        if mounts then self:RegisterEvent("NEW_MOUNT_ADDED") end
        if pets then self:RegisterEvent("PET_JOURNAL_LIST_UPDATE") end
        if toys then
            self:RegisterEvent("NEW_TOY_ADDED")
            self:RegisterEvent("TOYS_UPDATED")
        end
    end
    if not Enabled("qolUnwrapCollections") or collectionBusy then return end
    if (event == "NEW_TOY_ADDED" or event == "TOYS_UPDATED") and type(id) == "number" then
        pendingToys[id] = true
    end
    QueueCollectionUnwrap()
end)

local function FormatMoney(money)
    local formatter = C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString or GetCoinTextureString
    if formatter then return formatter(money) end
    return string.format(L.qolMoneyFormat, math.floor(money / 10000), math.floor(money / 100) % 100, money % 100)
end

local function Say(key, money)
    print("|cffd9ad38WoWTR:|r " .. (money and string.format(L[key], FormatMoney(money)) or L[key]))
end

-- Logging has its own events and does not depend on merchant/container APIs.
local logFrame = CreateFrame("Frame")
local logCheckTimer, logStopTimer
local logEventsRegistered = false
local LOG_STOP_DELAY = 30
local logEvents = { "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "PLAYER_DIFFICULTY_CHANGED" }

local function CancelLogCheck()
    if logCheckTimer then logCheckTimer:Cancel(); logCheckTimer = nil end
end

local function CancelLogStop()
    if logStopTimer then logStopTimer:Cancel(); logStopTimer = nil end
end

local function UpdateLog(stopNow)
    if not LoggingCombat or not GetInstanceInfo then return end
    QTR_PS = QTR_PS or {}
    local logging = LoggingCombat()
    -- Persist only logs started by WoWTR so /reload does not lose ownership.
    if not logging then QTR_PS.qolCombatLogOwned = nil end
    local _, kind = GetInstanceInfo()
    local shouldLog = Enabled("qolCombatLog") and (kind == "party" or kind == "raid")
    if shouldLog then
        CancelLogStop()
        local getCVar = C_CVar and C_CVar.GetCVar or GetCVar
        local setCVar = C_CVar and C_CVar.SetCVar or SetCVar
        if getCVar and setCVar and getCVar("advancedCombatLogging") ~= "1" then
            setCVar("advancedCombatLogging", "1")
        end
        if not logging then
            LoggingCombat(true)
            if LoggingCombat() then
                QTR_PS.qolCombatLogOwned = true
                Say("qolCombatLogStarted")
            end
        end
    elseif QTR_PS.qolCombatLogOwned then
        if stopNow or not Enabled("qolCombatLog") then
            CancelLogStop()
            LoggingCombat(false)
            if not LoggingCombat() then
                QTR_PS.qolCombatLogOwned = nil
                Say("qolCombatLogStopped")
            end
        elseif not logStopTimer then
            -- Keep short exits/loading transitions from splitting the log.
            logStopTimer = C_Timer.NewTimer(LOG_STOP_DELAY, function()
                logStopTimer = nil
                UpdateLog(true) -- Recheck the zone in case the player reentered.
            end)
        end
    else
        CancelLogStop()
    end
end

local function QueueLogCheck(delay)
    CancelLogCheck()
    if not Enabled("qolCombatLog") then return end
    logCheckTimer = C_Timer.NewTimer(delay, function()
        logCheckTimer = nil
        UpdateLog()
    end)
end

local function ApplyLogSettings()
    local enabled = Enabled("qolCombatLog") and true or false
    if enabled ~= logEventsRegistered then
        logEventsRegistered = enabled
        for _, event in ipairs(logEvents) do
            if enabled then logFrame:RegisterEvent(event) else logFrame:UnregisterEvent(event) end
        end
        if C_ChallengeMode then
            if enabled then logFrame:RegisterEvent("CHALLENGE_MODE_START")
            else logFrame:UnregisterEvent("CHALLENGE_MODE_START") end
        end
    end
    UpdateLog()
    QueueLogCheck(2)
end

logFrame:RegisterEvent("PLAYER_LOGIN")
logFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")
        ApplyLogSettings()
    else
        -- Instance data can still describe the previous zone during the event.
        QueueLogCheck(event == "CHALLENGE_MODE_START" and 1 or 2)
    end
end)

local visit = 0
local function Repair(silentNoMoney, afterRepair)
    if not merchant or not Enabled("qolRepair") or InCombatLockdown() or not CanMerchantRepair() then return end
    local cost, needed = GetRepairAllCost()
    if not needed or cost <= 0 then return end
    if GetMoney() < cost then
        if not silentNoMoney then Say("qolRepairNoMoney") end
        return
    end
    local before, token = GetMoney(), visit
    RepairAllItems(false)
    C_Timer.After(0.6, function()
        if token ~= visit or not merchant then return end
        local paid = before - GetMoney()
        if paid > 0 then Say("qolRepairResult", math.min(cost, paid)) end
        -- Start sales after the repair receipt so sale income cannot mask its cost.
        if afterRepair then afterRepair() end
    end)
    return true
end

local function CanSellJunk()
    if not merchant or not Enabled("qolSellJunk") or InCombatLockdown() then return false end
    local api = C_MerchantFrame
    -- Use the same availability check as Blizzard's sell-all-junk button.
    return not (api and api.SellAllJunkItems and api.IsSellAllJunkEnabled)
        or api.IsSellAllJunkEnabled()
end

local function SellJunk(retryRepair)
    if not CanSellJunk() then
        if retryRepair then Repair() end
        return
    end
    if busy then
        local token = visit
        C_Timer.After(0.6, function()
            if merchant and token == visit then SellJunk(retryRepair) end
        end)
        return
    end
    busy = true
    local token, total, attempted = visit, 0, {}
    local bulkSell = C_MerchantFrame and C_MerchantFrame.SellAllJunkItems
    local function Finish()
        busy = false
        -- Native bulk selling already prints the game's money message.
        if total > 0 and not bulkSell then Say("qolSellResult", total) end
        if retryRepair and token == visit then Repair() end
    end
    if bulkSell then
        if not CanSellJunk() then Finish(); return end
        local before, expected = GetMoney(), 0
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetBagSlots(bag) do
                local info = GetBagItem(bag, slot)
                if info and info.quality == 0 and not info.hasNoValue then
                    local price = select(11, GetItemDetails(info.itemID or info.hyperlink))
                    expected = expected + (price or 0) * (info.stackCount or 1)
                end
            end
        end
        -- Same operation as Blizzard's sell-all-junk button: no per-item delay.
        bulkSell()
        local checks, previous = 0, 0
        local function CheckSale()
            checks = checks + 1
            local gained = math.max(0, GetMoney() - before)
            total = math.min(expected, gained)
            if token ~= visit or not merchant or checks >= 6
                or (total >= expected) or (total > 0 and total == previous) then
                Finish()
                return
            end
            previous = total
            C_Timer.After(0.3, CheckSale)
        end
        C_Timer.After(0.3, CheckSale)
        return
    end
    -- Compatibility path for clients without the bulk merchant API.
    local function Next()
        if token ~= visit or not CanSellJunk() then Finish(); return end
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetBagSlots(bag) do
                local info = GetBagItem(bag, slot)
                local key = bag .. ":" .. slot
                if info and info.quality == 0 and not info.isLocked and not info.hasNoValue and not attempted[key] then
                    local price = select(11, GetItemDetails(info.itemID or info.hyperlink))
                    if price and price > 0 then
                        attempted[key] = true
                        local before, count = GetMoney(), info.stackCount or 1
                        UseBagItem(bag, slot)
                        C_Timer.After(0.5, function()
                            local after = GetBagItem(bag, slot)
                            if not after or after.itemID ~= info.itemID or (after.stackCount or 1) < count then
                                total = total + math.min(price * count, math.max(0, GetMoney() - before))
                            end
                            Next()
                        end)
                        return
                    end
                end
            end
        end
        Finish()
    end
    Next()
end

local function CanOpen()
    return Enabled("qolContainers") and not InCombatLockdown() and not merchant
        and not next(blocked) and not UnitCastingInfo("player") and not UnitChannelInfo("player")
        and not (MerchantFrame and MerchantFrame:IsShown())
        and not (MailFrame and MailFrame:IsShown()) and not (BankFrame and BankFrame:IsShown())
        and not (TradeFrame and TradeFrame:IsShown())
end

local opening = false
local openCheck
local containerEnabled = false
local openGeneration = 0
local tooltipRetries = {}
local scanTooltip
local function GetBagTooltip(bag, slot)
    if C_TooltipInfo and C_TooltipInfo.GetBagItem then return C_TooltipInfo.GetBagItem(bag, slot) end
    -- Era/TBC lack the structured bag tooltip API. Use a private, hidden tooltip
    -- so locked boxes can still be distinguished from openable loot containers.
    if not scanTooltip then
        scanTooltip = CreateFrame("GameTooltip", "WOWTR_QoLScanTooltip", UIParent, "GameTooltipTemplate")
    end
    scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    scanTooltip:ClearLines()
    scanTooltip:SetBagItem(bag, slot)
    local lines = {}
    for index = 1, scanTooltip:NumLines() do
        local text = _G["WOWTR_QoLScanTooltipTextLeft" .. index]
        lines[#lines + 1] = { leftText = text and text:GetText() }
    end
    scanTooltip:Hide()
    if #lines > 0 then return { lines = lines } end
end

local function PlainTooltipText(text)
    if type(text) ~= "string" then return "" end
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        :gsub("|n", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function ContainerIsOpenable(info, tip)
    if not tip then return false end -- Wait until the tooltip can rule out a lock.
    local openable = info.hasLoot == true
    local openText = PlainTooltipText(ITEM_OPENABLE)
    for _, line in ipairs(tip and tip.lines or {}) do
        local text = PlainTooltipText(line.leftText)
        -- Slot isLocked means a transaction is pending; this is the actual lock label.
        if text ~= "" and (text == PlainTooltipText(LOCKED) or text == PlainTooltipText(ITEM_LOCKED)) then
            return false
        end
        if text ~= "" and ((openText ~= "" and text == openText) or text == L.qolOpenableText) then
            openable = true
        end
    end
    return openable
end
local ScanContainers
local function QueueScan()
    if pendingScan or not Enabled("qolContainers") then return end
    pendingScan = true
    C_Timer.After(0.5, function()
        pendingScan = false
        ScanContainers()
    end)
end

ScanContainers = function()
    if opening or not CanOpen() then return end
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetBagSlots(bag) do
            local info = GetBagItem(bag, slot)
            if info and info.itemID and not info.isLocked and not failedContainers[info.itemID] then
                local tip = GetBagTooltip(bag, slot)
                local openable = ContainerIsOpenable(info, tip)
                -- Retry partial tooltips too: item names can arrive before the open line.
                if not openable then
                    local tries = tooltipRetries[info.itemID] or 0
                    if tries < 3 then
                        tooltipRetries[info.itemID] = tries + 1
                        QueueScan()
                    end
                else
                    tooltipRetries[info.itemID] = nil
                end
                local start, duration = GetBagCooldown(bag, slot)
                if openable and (not start or start == 0 or duration == 0) then
                    opening = true
                    local generation = openGeneration
                    local itemID, count = info.itemID, info.stackCount or 1
                    UseBagItem(bag, slot)
                    local function VerifyOpen()
                        if generation ~= openGeneration then return end
                        if blocked.loot then openCheck = VerifyOpen; return end
                        openCheck = nil
                        opening = false
                        local after = GetBagItem(bag, slot)
                        if not after or after.itemID ~= itemID or (after.stackCount or 1) < count then
                            failedContainers[itemID] = nil
                        elseif not after.isLocked then
                            -- A locked item is still processing, not a failed open.
                            failedContainers[itemID] = true
                        end
                        QueueScan()
                    end
                    C_Timer.After(1, VerifyOpen)
                    return
                end
            end
        end
    end
end

function WOWTR_QoLApply()
    QTR_PS = QTR_PS or {}
    for _, key in ipairs(keys) do
        if QTR_PS[key] == nil then QTR_PS[key] = "0" end
    end
    local enabled = Enabled("qolContainers")
    if enabled ~= containerEnabled then
        containerEnabled = enabled
        openGeneration = openGeneration + 1
        opening, openCheck = false, nil
        failedContainers, tooltipRetries = {}, {}
    end
    ApplyLogSettings()
    QueueScan()
    QueueCollectionUnwrap()
end

local gates = {
    MAIL_SHOW = {"mail", true}, MAIL_CLOSED = {"mail", false},
    BANKFRAME_OPENED = {"bank", true}, BANKFRAME_CLOSED = {"bank", false},
    TRADE_SHOW = {"trade", true}, TRADE_CLOSED = {"trade", false},
    LOOT_OPENED = {"loot", true}, LOOT_CLOSED = {"loot", false},
}
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        -- Each feature checks its own APIs; missing bags must not disable repair.
        for _, name in ipairs({"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "MERCHANT_SHOW", "MERCHANT_CLOSED",
            "BAG_UPDATE_DELAYED", "ITEM_LOCK_CHANGED", "GET_ITEM_INFO_RECEIVED", "PLAYER_REGEN_ENABLED",
            "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP"}) do
            frame:RegisterEvent(name)
        end
        if C_PlayerInteractionManager then
            frame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
        end
        for name in pairs(gates) do frame:RegisterEvent(name) end
        WOWTR_QoLApply()
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        local types = Enum and Enum.PlayerInteractionType
        if types then
            if unit == types.MailInfo then blocked.mail = nil end
            if unit == types.Banker or unit == types.AccountBanker then blocked.bank = nil end
        end
        QueueScan()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        QueueScan()
    elseif event == "MERCHANT_SHOW" then
        merchant = true
        visit = visit + 1
        if CanSellJunk() then
            -- Repair immediately; only insufficient funds need a retry after sales.
            if not Repair(true, function() SellJunk(false) end) then SellJunk(true) end
        else
            Repair()
        end
    elseif event == "MERCHANT_CLOSED" then
        merchant = false
        visit = visit + 1
        QueueScan()
    elseif gates[event] then
        local gate = gates[event]
        blocked[gate[1]] = gate[2] or nil
        if event == "LOOT_CLOSED" and openCheck then
            -- Wait for the server's bag update before judging whether loot was taken.
            local verify = openCheck
            openCheck = nil
            C_Timer.After(0.5, verify)
        end
        if not gate[2] then QueueScan() end
    elseif not event:find("UNIT_") or unit == "player" then
        QueueScan()
    end
end)

function WOWTR_CreateQoLPanel(parent)
    local panel = CreateFrame("Frame", "WOWTR_OptionPanel13", parent)
    panel:SetSize(815, 540)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 218, -112)
    panel:Hide()
    local function Text(value, x, y, size, gold)
        local label = panel:CreateFontString(nil, "ARTWORK")
        label:SetFont(WOWTR_Font2, size)
        label:SetPoint("TOPLEFT", x, y)
        label:SetWidth(740 - x)
        label:SetJustifyH("LEFT")
        label:SetWordWrap(true)
        label:SetTextColor(gold and 0.85 or 0.75, gold and 0.68 or 0.73, gold and 0.22 or 0.69)
        label:SetText(value)
        return label
    end
    Text(L.qolTitle, 20, 0, 18, true)
    Text(L.qolIntro, 20, -32, 13)
    for index, key in ipairs(keys) do
        local setting = key
        local y = -85 - (index - 1) * 85
        local checkbox = WOWTR_CreateModernCheckbox(nil, panel, L[setting .. "Label"], function(self)
            if not Supported(setting) then return end
            QTR_PS = QTR_PS or {}
            QTR_PS[setting] = self:GetChecked() and "1" or "0"
            WOWTR_QoLApply()
        end)
        checkbox:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, y)
        local description = Text(L[setting .. "Desc"], 72, y - 32, 13)
        local function Refresh(self)
            local supported = Supported(setting)
            self:SetEnabled(supported and true or false)
            self:SetChecked(Enabled(setting) and true or false)
            description:SetText(supported and L[setting .. "Desc"]
                or (setting == "qolUnwrapCollections" and L.qolUnwrapCollectionsUnavailable or L.qolUnavailable))
        end
        checkbox:HookScript("OnShow", Refresh)
        Refresh(checkbox)
    end
end
