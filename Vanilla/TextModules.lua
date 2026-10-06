local W = WoWTRV

local interfaceLabels = {
    Accept="Kabul Et", Decline="Reddet", Continue="Devam", Complete="Tamamla",
    ["Complete Quest"]="Görevi Tamamla", Goodbye="Hoşça Kal", ["Abandon Quest"]="Görevi Bırak",
    ["Share Quest"]="Görevi Paylaş", ["Track Quest"]="Görevi Takip Et", ["Untrack Quest"]="Takibi Bırak",
    Description="Açıklama", Objectives="Hedefler", Rewards="Ödüller",
    ["Current Quests"]="Mevcut Görevler", ["Available Quests"]="Alınabilir Görevler",
    Backpack="Sırt Çantası", Keyring="Anahtarlık", Character="Karakter", Pet="Evcil Hayvan",
    Reputation="İtibar", Skills="Beceriler", Honor="Onur", ["Main Menu"]="Ana Menü",
    ["Video Options"]="Görüntü Ayarları", ["Sound Options"]="Ses Ayarları",
    ["Interface Options"]="Arayüz Ayarları", ["Key Bindings"]="Tuş Atamaları",
    Video="Görüntü", Sound="Ses", Interface="Arayüz", Keybindings="Tuş Atamaları",
    Macros="Makrolar", Logout="Çıkış Yap", ["Log Out"]="Çıkış Yap",
    ["Exit Game"]="Oyundan Çık", ["Return to Game"]="Oyuna Dön",
}

local interfaceWidgets = {"QuestFrameAcceptButton", "QuestFrameDeclineButton", "QuestFrameCompleteButton", "QuestFrameCompleteQuestButton", "QuestFrameGoodbyeButton", "QuestLogFrameAbandonButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "GossipFrameGreetingGoodbyeButton", "QuestFrameGreetingGoodbyeButton", "QuestLogDescriptionTitle", "QuestLogRewardTitleText", "QuestLogObjectivesTitle", "QuestDetailObjectiveTitle", "QuestDetailDescriptionTitle", "QuestDetailRewardTitleText", "GameMenuButtonOptions", "GameMenuButtonSoundOptions", "GameMenuButtonUIOptions", "GameMenuButtonKeybindings", "GameMenuButtonMacros", "GameMenuButtonLogout", "GameMenuButtonQuit", "GameMenuButtonContinue"}
for i = 1, 12 do table.insert(interfaceWidgets, "ContainerFrame" .. i .. "Name") end
for i = 1, 5 do table.insert(interfaceWidgets, "CharacterFrameTab" .. i) end
local uiHooked = setmetatable({}, {__mode = "k"})
local uiBusy = setmetatable({}, {__mode = "k"})

local function translateInterface(widget)
    if not W.Active("ui") or uiBusy[widget] or not widget or not widget.GetText then return end
    local current = widget:GetText()
    local previous = W.originals[widget]
    if previous and current == previous.translated then return end
    if previous then
        local font = widget.GetFont and widget:GetFont()
        if font == W.font and previous.font then widget:SetFont(previous.font, previous.size, previous.flags) end
        W.originals[widget] = nil
    end
    local translation = current and (interfaceLabels[current] or W.FindTranslation("tooltips", current, false))
    if translation then
        uiBusy[widget] = true
        W.Protected("interface.text", W.Replace, widget, translation, "ui")
        uiBusy[widget] = nil
    end
end

local function hookInterface(object, widget)
    if not object or uiHooked[object] or type(object.SetText) ~= "function" then return end
    local old = object.SetText
    object.SetText = function(...)
        local results = W.Capture(old(unpack(arg)))
        W.Protected("interface.set", translateInterface, widget)
        return unpack(results)
    end
    uiHooked[object] = true
end

function W.InterfaceText()
    for _, name in ipairs(interfaceWidgets) do
        local object = _G[name]
        local widget = object
        if object and object.GetFontString then widget = object:GetFontString() or object end
        if widget and widget.GetText then
            hookInterface(widget, widget)
            hookInterface(object, widget)
            translateInterface(widget)
        end
    end
end

local tooltipSeen = setmetatable({}, {__mode = "k"})
local function translateTooltipLine(widget)
    if not widget or not widget.GetText then return end
    local current = widget:GetText()
    if tooltipSeen[widget] == current then return end
    W.TranslateWidget(widget, "tooltips", true, "tooltips")
    tooltipSeen[widget] = widget:GetText()
end

function W.Tooltip(tooltip, force)
    if not W.Active("tooltips") or not tooltip or (not force and not tooltip:IsShown()) then return end
    local name = tooltip:GetName()
    if not name then return end
    local count = tooltip.NumLines and tooltip:NumLines() or 30
    for i = 1, math.min(count, 60) do
        translateTooltipLine(_G[name .. "TextLeft" .. i])
        translateTooltipLine(_G[name .. "TextRight" .. i])
    end
end

local tooltipDepth = setmetatable({}, {__mode = "k"})
local tooltipBusy = setmetatable({}, {__mode = "k"})
local tooltipHooked = setmetatable({}, {__mode = "k"})
local function refreshTooltip(tooltip)
    if tooltipBusy[tooltip] or (tooltipDepth[tooltip] or 0) > 0 then return end
    tooltipBusy[tooltip] = true
    W.Protected("tooltip.refresh", W.Tooltip, tooltip, true)
    tooltipBusy[tooltip] = nil
end

local function tooltipWrapper(tooltip, old)
    return function(...)
        -- Translate only after the entire existing hook chain has built its lines.
        -- pcall ensures a failing third-party hook cannot leave the depth stuck.
        tooltipDepth[tooltip] = (tooltipDepth[tooltip] or 0) + 1
        local results = W.Capture(pcall(old, unpack(arg)))
        tooltipDepth[tooltip] = tooltipDepth[tooltip] - 1
        if not results[1] then error(results[2]) end
        refreshTooltip(tooltip)
        for i = 1, results.n - 1 do results[i] = results[i + 1] end
        results[results.n] = nil; results.n = results.n - 1
        return unpack(results)
    end
end

function W.HookTooltip(tooltip)
    if not tooltip or tooltipHooked[tooltip] then return end
    tooltipHooked[tooltip] = true
    for _, name in ipairs({"SetBagItem", "SetInventoryItem", "SetHyperlink", "SetLootItem", "SetLootRollItem", "SetMerchantItem", "SetQuestLogItem", "SetQuestItem", "SetInboxItem", "SetCraftItem", "SetCraftSpell", "SetTradeSkillItem", "SetAuctionItem", "SetAuctionSellItem", "SetTradePlayerItem", "SetTradeTargetItem", "SetSpell", "SetAction", "SetPetAction", "SetShapeshift", "SetUnit", "SetText", "AddLine", "AddDoubleLine", "AppendText", "Show"}) do
        if type(tooltip[name]) == "function" then tooltip[name] = tooltipWrapper(tooltip, tooltip[name]) end
    end
    for _, name in ipairs({"OnShow", "OnUpdate"}) do
        local old = tooltip:GetScript(name)
        tooltip:SetScript(name, tooltipWrapper(tooltip, old or function() end))
    end
end

function W.Tutorials()
    if not W.Active("tutorials") then return end
    for _, name in ipairs({"TutorialFrameText", "TutorialFrameTitle", "TutorialFrameTitleText"}) do
        W.TranslateWidget(_G[name], "tutorials", false, "tutorials")
    end
end

function W.Subtitle(text)
    if not W.Active("subtitles") or not text then return end
    local translation = W.FindTranslation("subtitles", text, false)
    if translation then
        if not W.subtitleFrame then
            local frame = W.NewFrame("Frame", "WoWTRVanillaSubtitles", UIParent)
            frame:SetWidth(720); frame:SetHeight(100)
            frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 115)
            frame:SetFrameStrata("FULLSCREEN_DIALOG")
            W.Backdrop(frame)
            frame.text = W.Text(frame, 18, "")
            frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
            frame.text:SetWidth(680)
            W.subtitleFrame = frame
        end
        W.subtitleFrame.text:SetText(translation)
        W.subtitleFrame:Show()
        W.Later(8, function() W.subtitleFrame:Hide() end, "subtitleHide")
    end
end

function W.MonsterChat(text, speaker)
    if not W.Active("bubbles") or not text then return end
    local translation = W.FindTranslation("bubbles", text, false)
    if translation then
        W.Message((speaker or "NPC") .. ": " .. translation)
        W.bubbleQueue[text] = {translation = translation, expires = GetTime() + 12}
    else W.Missing("bubble", W.Hash(W.Normalize(text, false)), text) end
end

local function inspectBubble(frame, depth)
    if not frame or depth > 2 or not frame:IsShown() then return end
    if frame.GetRegions then
        local regions = W.Capture(frame:GetRegions())
        for i = 1, regions.n do
            local region = regions[i]
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                local text = region:GetText()
                local candidate = text and W.bubbleQueue[text]
                if candidate then W.Replace(region, candidate.translation, "bubbles") end
            end
        end
    end
    if frame.GetChildren then
        local children = W.Capture(frame:GetChildren())
        for i = 1, children.n do inspectBubble(children[i], depth + 1) end
    end
end

function W.Bubbles()
    if not W.Active("bubbles") then return end
    local pending = false
    for source, value in pairs(W.bubbleQueue) do
        if value.expires < GetTime() then W.bubbleQueue[source] = nil else pending = true end
    end
    if not pending or not WorldFrame or not WorldFrame.GetChildren then return end
    local frames = W.Capture(WorldFrame:GetChildren())
    for i = 1, frames.n do
        local frame = frames[i]
        -- Bubble frames are anonymous; exclude named unit/nameplate/addon frames.
        if frame and frame.GetName and not frame:GetName() then inspectBubble(frame, 0) end
    end
end

function W.InitTextModules()
    W.bubbleQueue = {}
    W.HookTooltip(GameTooltip); W.HookTooltip(ItemRefTooltip)
    W.InterfaceText()
    for _, name in ipairs({"ContainerFrame_GenerateFrame", "ShowUIPanel", "QuestFrame_OnShow", "CharacterFrame_OnShow"}) do W.Hook(name, W.InterfaceText) end
    W.Hook("TutorialFrame_Update", function() W.Later(0.02, W.Tutorials, "tutorial") end)
    if CinematicFrame then
        local old = CinematicFrame:GetScript("OnHide")
        CinematicFrame:SetScript("OnHide", function()
            if old then old() end
            if W.subtitleFrame then W.subtitleFrame:Hide() end
        end)
    end
end
