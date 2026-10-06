local W = WoWTRV

local interfaceLabels = {
    Accept="Kabul Et", Decline="Reddet", Continue="Devam", Complete="Tamamla",
    ["Complete Quest"]="Görevi Tamamla", Goodbye="Hoşça Kal", ["Abandon Quest"]="Görevi Bırak",
    ["Share Quest"]="Görevi Paylaş", ["Track Quest"]="Görevi Takip Et", ["Untrack Quest"]="Takibi Bırak",
    Description="Açıklama", Objectives="Hedefler", Rewards="Ödüller",
    ["Current Quests"]="Mevcut Görevler", ["Available Quests"]="Alınabilir Görevler",
}

function W.InterfaceText()
    if not W.Active("ui") then return end
    for _, name in ipairs({"QuestFrameAcceptButton", "QuestFrameDeclineButton", "QuestFrameCompleteButton", "QuestFrameCompleteQuestButton", "QuestFrameGoodbyeButton", "QuestLogFrameAbandonButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "GossipFrameGreetingGoodbyeButton", "QuestFrameGreetingGoodbyeButton", "QuestLogDescriptionTitle", "QuestLogRewardTitleText", "QuestLogObjectivesTitle", "QuestDetailObjectiveTitle", "QuestDetailDescriptionTitle", "QuestDetailRewardTitleText"}) do
        local widget = _G[name]
        if widget and widget.GetFontString then widget = widget:GetFontString() end
        if widget and widget.GetText then
            local current = widget:GetText()
            local translation = current and (interfaceLabels[current] or W.FindTranslation("tooltips", current, false))
            if translation then W.Replace(widget, translation, "ui") end
        end
    end
end

function W.Tooltip(tooltip)
    if not W.Active("tooltips") or not tooltip or not tooltip:IsShown() then return end
    local name = tooltip:GetName()
    if not name then return end
    local count = tooltip.NumLines and tooltip:NumLines() or 30
    for i = 1, math.min(count, 60) do
        W.TranslateWidget(_G[name .. "TextLeft" .. i], "tooltips", true, "tooltips")
        W.TranslateWidget(_G[name .. "TextRight" .. i], "tooltips", true, "tooltips")
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
    W.Hook("TutorialFrame_Update", function() W.Later(0.02, W.Tutorials, "tutorial") end)
    if CinematicFrame then
        local old = CinematicFrame:GetScript("OnHide")
        CinematicFrame:SetScript("OnHide", function()
            if old then old() end
            if W.subtitleFrame then W.subtitleFrame:Hide() end
        end)
    end
end
