local W = WoWTRV
local hooked = setmetatable({}, {__mode = "k"})
local busy = setmetatable({}, {__mode = "k"})
local shownHooked = setmetatable({}, {__mode = "k"})
local messageFont
function W.UpdateMessageFont()
    if not UIErrorsFrame or not messageFont or not UIErrorsFrame.SetFont then return end
    UIErrorsFrame:SetFont(W.Active("ui") and W.font or messageFont[1], messageFont[2], messageFont[3])
end

local function hookMessages()
    if not UIErrorsFrame or UIErrorsFrame.wowtrMessages or type(UIErrorsFrame.AddMessage) ~= "function" then return end
    if UIErrorsFrame.GetFont then messageFont = W.Capture(UIErrorsFrame:GetFont()) end
    local old = UIErrorsFrame.AddMessage
    UIErrorsFrame.AddMessage = function(...)
        if W.Active("ui") and type(arg[2]) == "string" then
            local translation = W.DisplayTranslation(arg[2], true)
            if translation then arg[2] = translation else W.RecordUntranslated("ui.error", arg[2]) end
        end
        return old(unpack(arg))
    end
    UIErrorsFrame.wowtrMessages = true
    W.UpdateMessageFont()
end
local roots = {"QuestFrame", "QuestLogFrame", "QuestWatchFrame", "SpellBookFrame", "CharacterFrame", "SkillFrame", "PaperDollFrame", "TalentFrame", "GameMenuFrame", "OptionsFrame", "SoundOptionsFrame", "UIOptionsFrame", "KeyBindingFrame", "BankFrame", "MerchantFrame", "TradeFrame", "TradeSkillFrame", "CraftFrame", "ClassTrainerFrame", "PetStableFrame", "MailFrame", "SendMailFrame", "OpenMailFrame", "GossipFrame", "ItemTextFrame", "LootFrame", "WorldMapFrame", "MinimapCluster", "PlayerFrame", "TargetFrame", "AuctionFrame", "MacroFrame", "ReputationFrame", "HonorFrame", "HelpFrame", "TutorialFrame"}
for i = 1, 12 do table.insert(roots, "ContainerFrame" .. i) end
for i = 1, 4 do table.insert(roots, "StaticPopup" .. i) end
local standalone = {"MinimapZoneText", "ZoneTextString", "SubZoneTextString", "PlayerFrameHealthBarText", "PlayerFrameManaBarText", "MainMenuExpBarText", "QuestFrameAcceptButton", "QuestFrameDeclineButton", "QuestFrameCompleteButton", "QuestFrameCompleteQuestButton", "QuestFrameGoodbyeButton", "QuestLogFrameAbandonButton", "QuestFramePushQuestButton", "QuestFrameExitButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "GameMenuButtonContinue"}
-- These carry source text used by the dedicated translators, or player/NPC names.
local excluded = {QuestTitleText=true, QuestDescription=true, QuestObjectiveText=true,
    QuestProgressTitleText=true, QuestProgressText=true, QuestRewardTitleText=true, QuestRewardText=true,
    QuestLogQuestTitle=true, QuestLogQuestDescription=true, QuestLogObjectivesText=true,
    GreetingText=true, GossipGreetingText=true, ItemTextPageText=true, ItemTextTitleText=true,
    PlayerName=true, TargetName=true, TargetFrameTextureFrameName=true, PetName=true,
    CharacterNameText=true, QuestFrameNpcNameText=true, GossipFrameNpcNameText=true,
    MerchantNameText=true, BankFrameTitleText=true, TradeFramePlayerNameText=true, TradeFrameRecipientNameText=true,
    MailSenderText=true, OpenMailSender=true, OpenMailSubject=true, OpenMailBodyText=true,
    MacroFrameSelectedMacroName=true, MacroFrameText=true,
    TutorialFrameText=true, TutorialFrameTitle=true, TutorialFrameTitleText=true}

local function questLabel(name)
    return name and (string.find(name, "^QuestLogTitle%d") or string.find(name, "^QuestTitleButton%d") or string.find(name, "^QuestWatchLine%d"))
end

function W.QuestTitleTranslation(text, widget)
    if not W.Active("quests") or not W.db.questTitles or W.readerEnglish or type(text) ~= "string" then return end
    local source = W.Trim(text)
    local objectives = ""
    local name = widget and widget.GetName and widget:GetName()
    local _, _, row = string.find(name or "", "^QuestLogTitle(%d+)")
    if row and GetQuestLogSelection and GetQuestLogTitle and GetQuestLogQuestText then
        local offset = FauxScrollFrame_GetOffset and QuestLogListScrollFrame and FauxScrollFrame_GetOffset(QuestLogListScrollFrame) or 0
        local selected = GetQuestLogSelection()
        if selected == tonumber(row) + offset and GetQuestLogTitle(selected) == source then
            local _, objectiveText = GetQuestLogQuestText()
            objectives = objectiveText or ""
        end
    end
    local id = W.ResolveQuest(source, objectives)
    local record = id and W.Quests[tostring(id)]
    if record and record.Title then
        local _, _, prefix = string.find(text, "^(%s*)")
        return (prefix or "") .. W.Format(record.Title)
    end
end

local function translate(widget, role)
    if not widget or not W.Active("ui") or busy[widget] or not widget.GetText then return end
    local source = widget:GetText()
    if role == "quest" and W.Titles[W.Trim(source)] and (not W.Active("quests") or not W.db.questTitles or W.readerEnglish) then return end
    local previous = W.originals[widget]
    if previous and source == previous.translated then return end
    W.ClearReusedWidget(widget)
    local translation
    if role == "quest" then translation = W.QuestTitleTranslation(source, widget) end
    translation = translation or W.DisplayTranslation(source, true)
    if translation then
        busy[widget] = true
        W.Protected("interface.text", W.Replace, widget, translation, role == "quest" and "quests" or "ui")
        busy[widget] = nil
    elseif not widget.IsShown or widget:IsShown() then W.RecordUntranslated("ui", source) end
end

local function hookText(object, widget, role)
    if not object or hooked[object] or type(object.SetText) ~= "function" then return end
    local old = object.SetText
    object.SetText = function(...)
        local results = W.Capture(old(unpack(arg)))
        W.Protected("interface.set", translate, widget, role)
        return unpack(results)
    end
    hooked[object] = true
end

local function eligible(object)
    local name = object.GetName and object:GetName()
    if name and (excluded[name] or string.find(name, "^WoWTR") or string.find(name, "^PartyMemberFrame%dName") or string.find(name, "^GossipTitleButton%d")) then return false end
    local kind = object.GetObjectType and object:GetObjectType()
    return kind ~= "EditBox" and kind ~= "ScrollingMessageFrame" and kind ~= "MessageFrame" and kind ~= "GameTooltip"
end

function W.ScanInterface(frame, depth)
    depth = depth or 0
    if not frame or depth > 12 or not eligible(frame) then return end
    local name = frame.GetName and frame:GetName()
    local role = questLabel(name) and "quest" or "ui"
    local font = frame.GetFontString and frame:GetFontString()
    if font then hookText(frame, font, role); hookText(font, font, role); translate(font, role)
    elseif frame.GetObjectType and frame:GetObjectType() == "FontString" then hookText(frame, frame, role); translate(frame, role) end
    if frame.GetRegions then
        local regions = W.Capture(frame:GetRegions())
        for i = 1, regions.n do
            local region = regions[i]
            if region and region ~= font and region.GetObjectType and region:GetObjectType() == "FontString" then W.ScanInterface(region, depth + 1) end
        end
    end
    if frame.GetChildren then
        local children = W.Capture(frame:GetChildren())
        for i = 1, children.n do W.ScanInterface(children[i], depth + 1) end
    end
end

function W.InterfaceText()
    hookMessages(); W.UpdateMessageFont()
    for _, name in ipairs(roots) do
        local frame = _G[name]
        if frame then
            W.ScanInterface(frame)
            if not shownHooked[frame] and frame.GetScript and frame.SetScript then
                local old = frame:GetScript("OnShow")
                local target = frame
                frame:SetScript("OnShow", function()
                    if old then old() end
                    W.Protected("interface.show", W.ScanInterface, target)
                end)
                shownHooked[frame] = true
            end
        end
    end
    for _, name in ipairs(standalone) do if _G[name] then W.ScanInterface(_G[name]) end end
end
