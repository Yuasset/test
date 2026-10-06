local W = WoWTRV

function W.SellGrey()
    if not W.db.enabled or not W.db.sellGrey or not MerchantFrame or not MerchantFrame:IsShown() then return end
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local _, _, locked = GetContainerItemInfo(bag, slot)
            if link and not locked then
                local _, _, id = string.find(link, "item:(%d+)")
                if id then
                    local _, _, quality = GetItemInfo(tonumber(id))
                    if quality == 0 then UseContainerItem(bag, slot) end
                end
            end
        end
    end
end

function W.CheckCombatLog()
    if not LoggingCombat then return end
    local inInstance = IsInInstance and IsInInstance()
    local enabled = W.db.enabled and W.db.combatLog and inInstance and true or false
    if enabled and not W.ownsCombatLog then
        if not LoggingCombat() then LoggingCombat(true); W.ownsCombatLog = true end
    elseif not enabled and W.ownsCombatLog then LoggingCombat(false); W.ownsCombatLog = false end
end

function W.Initialize()
    if W.initialized then return end
    if type(WoWTRVanillaDB) ~= "table" then WoWTRVanillaDB = {} end
    W.db = WoWTRVanillaDB
    for key, value in pairs(W.defaults) do if W.db[key] == nil then W.db[key] = value end end
    W.db.questBindings = W.db.questBindings or {}
    W.db.fontSize = math.max(10, math.min(22, tonumber(W.db.fontSize) or 14))
    if type(WoWTRVanillaLog) ~= "table" then WoWTRVanillaLog = {} end
    WoWTRVanillaLog.errors = WoWTRVanillaLog.errors or {}; WoWTRVanillaLog.missing = WoWTRVanillaLog.missing or {}
    W.initialized = true
    W.Protected("quests.init", W.InitQuests); W.Protected("gossip.init", W.InitGossipBooks)
    W.Protected("text.init", W.InitTextModules); W.Protected("minimap.init", W.CreateMinimap)
    SLASH_WOWTRV1 = "/wowtr"
    SlashCmdList.WOWTRV = function(message) W.Protected("command", W.Slash, message) end
    if type(IsAddOnLoaded) == "function" and IsAddOnLoaded("QuestTranslator-Vanilla-Turkish") then
        W.Message("İki çeviri eklentisi aynı metinleri değiştirebilir. QuestTranslator'ı kapatıp WoWTR'yi tek başına deneyin.")
    end
    W.Message(W.version .. " yüklendi. Ayarlar: /wowtr · Durum: /wowtr durum")
end

function W.OnEvent(eventName, value, speaker)
    if eventName == "ADDON_LOADED" and value == "WoWTR" then W.Initialize(); return end
    if eventName == "PLAYER_LOGIN" then W.Initialize(); W.CheckCombatLog(); return end
    if not W.initialized then return end
    if eventName == "QUEST_DETAIL" then W.QuestEvent("details")
    elseif eventName == "QUEST_PROGRESS" then W.QuestEvent("progress")
    elseif eventName == "QUEST_COMPLETE" then W.QuestEvent("reward")
    elseif eventName == "QUEST_FINISHED" then
        if W.reader then W.reader:Hide() end
        W.questContext = nil; W.Later(0.1, W.QuestLog, "questLog")
    elseif eventName == "QUEST_LOG_UPDATE" then W.Later(0.1, W.QuestLog, "questLog")
    elseif eventName == "GOSSIP_SHOW" or eventName == "QUEST_GREETING" then W.Restore("gossip"); W.Later(0.05, W.Gossip, "gossip")
    elseif eventName == "GOSSIP_CLOSED" then W.Restore("gossip")
    elseif eventName == "ITEM_TEXT_BEGIN" or eventName == "ITEM_TEXT_READY" then W.Restore("books"); W.Later(0.08, W.Book, "book")
    elseif eventName == "ITEM_TEXT_CLOSED" then W.Restore("books")
    elseif eventName == "CHAT_MSG_MONSTER_SAY" or eventName == "CHAT_MSG_MONSTER_YELL" or eventName == "CHAT_MSG_MONSTER_WHISPER" or eventName == "CHAT_MSG_MONSTER_EMOTE" then W.MonsterChat(value, speaker)
    elseif eventName == "CINEMATIC_STOP" then if W.subtitleFrame then W.subtitleFrame:Hide() end
    elseif eventName == "CINEMATIC_START" then W.Later(0.15, W.CheckSubtitleWidget, "subtitle")
    elseif eventName == "MERCHANT_SHOW" then W.Later(0.3, W.SellGrey, "vendor")
    elseif eventName == "PLAYER_ENTERING_WORLD" or eventName == "ZONE_CHANGED_NEW_AREA" then W.CheckCombatLog() end
end

function W.CheckSubtitleWidget()
    if not W.Active("subtitles") then return end
    for _, widget in ipairs({CinematicFrameSubtitle or false, CinematicFrameSubtitles or false, MovieFrameSubtitle or false}) do
        if widget and widget.GetText then W.TranslateWidget(widget, "subtitles", false, "subtitles") end
    end
    if CinematicFrame and CinematicFrame.Subtitle and CinematicFrame.Subtitle.GetText then W.TranslateWidget(CinematicFrame.Subtitle, "subtitles", false, "subtitles") end
end

local ticker = W.NewFrame("Frame", "WoWTRVanillaEvents", UIParent)
W.events = ticker
for _, name in ipairs({"ADDON_LOADED", "PLAYER_LOGIN", "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED", "QUEST_LOG_UPDATE", "QUEST_GREETING", "GOSSIP_SHOW", "GOSSIP_CLOSED", "ITEM_TEXT_BEGIN", "ITEM_TEXT_READY", "ITEM_TEXT_CLOSED", "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_WHISPER", "CHAT_MSG_MONSTER_EMOTE", "CINEMATIC_START", "CINEMATIC_STOP", "MERCHANT_SHOW", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA"}) do ticker:RegisterEvent(name) end
ticker:SetScript("OnEvent", function() W.Protected("event." .. tostring(event), W.OnEvent, event, arg1, arg2) end)
local elapsed = 0
ticker:SetScript("OnUpdate", function()
    if not W.initialized then return end
    local delta = tonumber(arg1) or 0
    for index = table.getn(W.timers), 1, -1 do
        local timer = W.timers[index]; timer.delay = timer.delay - delta
        if timer.delay <= 0 then table.remove(W.timers, index); W.Protected("timer." .. (timer.key or "anonymous"), timer.fn) end
    end
    if W.minimapDragging then W.Protected("minimap.drag", W.MinimapDrag) end
    elapsed = elapsed + delta
    if elapsed < 0.2 then return end
    elapsed = 0
    W.Protected("tooltip.game", W.Tooltip, GameTooltip); W.Protected("tooltip.item", W.Tooltip, ItemRefTooltip)
    W.Protected("bubbles", W.Bubbles); W.Protected("tutorial", W.Tutorials); W.Protected("subtitles", W.CheckSubtitleWidget)
    W.Protected("interface", W.InterfaceText)
    if W.reader and W.reader:IsShown() and W.questContext and W.questContext.parent and not W.questContext.parent:IsShown() then W.reader:Hide() end
end)
