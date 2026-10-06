-- ============================================================================
-- WoWTR - DialogueUI uyumluluk ve entegrasyon köprüsü
-- ============================================================================
-- DialogueUI çeviri API'si, C_GossipInfo sarmalayıcıları, arayüz kancaları ve font değişiklikleriyle uyumluluk sağlar.
-- Metin kırpılmasını ("..."), çift dil (EN+TR) kirliliğini ve başlık kaymasını çözer.

local bridgeInitialized = false
local translatorRegistered = false
local gossipShowOriginal = false
local originalGossipTextGetter
local originalGossipOptionsGetter
WOWTR_DialogueUIBridgeActive = false

-- Font yolu yardımcısı (WOWTR_Font2 veya doğrudan frizquadrata_tr.ttf)
local function GetTRFont()
    return WOWTR_Font2 or "Interface\\AddOns\\WoWTR\\Fonts\\frizquadrata_tr.ttf"
end

-- Hata güvenli yardımcı işlevler
local function SafeDetectPlayerName(txt, target, part)
    if target == "" then target = nil end
    if WOWTR_DetectAndReplacePlayerName then
        return WOWTR_DetectAndReplacePlayerName(txt, target, part)
    end
    return txt
end

local function SafeDeleteSpecialCodes(txt, part)
    if WOWTR_DeleteSpecialCodes then
        return WOWTR_DeleteSpecialCodes(txt, part)
    end
    return txt
end

local function SafeStringHash(text)
    if _G.StringHash then
        return _G.StringHash(text)
    end
    if not text or (#text == 0) then return 0 end
    local counter = 1
    local pomoc = 0
    local dlug = string.len(text)
    for i = 1, dlug, 3 do 
        counter = math.fmod(counter * 8161, 4294967279)
        pomoc = (string.byte(text, i) * 16776193)
        counter = counter + pomoc
        pomoc = ((string.byte(text, i + 1) or (dlug - i + 256)) * 8372226)
        counter = counter + pomoc
        pomoc = ((string.byte(text, i + 2) or (dlug - i + 256)) * 3932164)
        counter = counter + pomoc
    end
    return math.fmod(counter, 4294967291)
end

local function CanAccessDialogueValue(value)
    if canaccessvalue then
        local ok, accessible = pcall(canaccessvalue, value)
        return ok and accessible
    end
    if issecretvalue then
        local ok, secret = pcall(issecretvalue, value)
        return ok and not secret
    end
    return true
end

-- DialogueUI'a ait font nesnelerinin listesi
local DUI_FONT_OBJECTS = {
    "DUIFont_Quest_Title_18",
    "DUIFont_Quest_Title_16",
    "DUIFont_Quest_SubHeader",
    "DUIFont_Quest_Paragraph",
    "DUIFont_Quest_Gossip",
    "DUIFont_Quest_Quest",
    "DUIFont_Quest_Disabled",
    "DUIFont_Quest_MultiLanguage",
    "DUIFont_Settings_Disabled",
    "DUIFont_Item",
    "DUIFont_ItemSelect",
    "DUIFont_QuestType_Right",
    "DUIFont_QuestType_Left",
    "DUIFont_Hotkey",
    "DUIFont_AlertFont",
    "DUIFont_ChatFont",
    "DUIFont_Tooltip_Large",
    "DUIFont_Tooltip_Medium",
    "DUIFont_Tooltip_Small",
    "DUIFont_NameplateGossip",
    "DUIFont_MenuButton_Normal",
    "DUIFont_MenuButton_Highlight",
    "DUIFont_AlertHeader",
    "DUIFont_Book_Title",
    "DUIFont_Book_H3",
    "DUIFont_Book_H2",
    "DUIFont_Book_H1",
    "DUIFont_Book_Paragraph",
    "DUIFont_Book_10",
}

-- ----------------------------------------------------------------------------
-- 1. Font Yönetimi: DialogueUI fontlarını Türkçe destekli frizquadrata_tr ile değiştir
-- ----------------------------------------------------------------------------
local isSettingFont = false
local function ApplyFontToDUIObject(fontObj)
    if not fontObj or not fontObj.GetFont or not fontObj.SetFont then return end
    local currentFont, height, flags = fontObj:GetFont()
    local targetFont = GetTRFont()
    if currentFont and currentFont ~= targetFont then
        isSettingFont = true
        fontObj:SetFont(targetFont, height, flags)
        isSettingFont = false
    end
end

local function SetupDialogueUIFonts()
    local targetFont = GetTRFont()
    for _, fontName in ipairs(DUI_FONT_OBJECTS) do
        local fontObj = _G[fontName]
        if fontObj and fontObj.GetFont and fontObj.SetFont then
            ApplyFontToDUIObject(fontObj)
            -- DialogueUI içinden font boyutu/stili değiştirildiğinde Türkçe fontun korunmasını sağla
            pcall(function()
                hooksecurefunc(fontObj, "SetFont", function(self, file, size, fl)
                    local desiredFont = GetTRFont()
                    if not isSettingFont and file ~= desiredFont then
                        isSettingFont = true
                        self:SetFont(desiredFont, size, fl)
                        isSettingFont = false
                    end
                end)
            end)
        end
    end
end

-- ----------------------------------------------------------------------------
-- 2. Görev Metin Temizleme ve Çeviri Verisi
-- ----------------------------------------------------------------------------
local function CleanQuestText(raw)
    if not raw or raw == "" then return nil end
    local text = SafeReplaceCodes(raw)
    text = string.gsub(text, "NEW_LINE", "\n")
    text = string.gsub(text, "$b", "\n")
    text = string.gsub(text, "$B", "\n")
    text = string.gsub(text, "{B}", "\n")
    text = string.gsub(text, "\r\n", "\n")
    text = string.gsub(text, "\r", "\n")
    text = string.gsub(text, " +$", "")
    return text
end

local function GetDUIQuestData(questID)
    if not questID then return nil end
    if not (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then
        return nil
    end

    local strID = tostring(questID)
    local qData = QTR_QuestData and QTR_QuestData[strID]
    if not qData then return nil end

    local title = CleanQuestText(qData["Title"])
    if not title or title == "" then return nil end

    return {
        title = title,
        description = CleanQuestText(qData["Description"]),
        objective = CleanQuestText(qData["Objectives"]),
        progress = CleanQuestText(qData["Progress"]),
        completion = CleanQuestText(qData["Completion"]),
    }
end

local function RegisterDialogueUITranslator()
    if translatorRegistered then return true end
    if not DialogueUIAPI or not DialogueUIAPI.SetTranslator then return false end

    local translator = {
        name = "WoWTR",
        font = GetTRFont(),
        questDataGetter = GetDUIQuestData,
    }

    DialogueUIAPI.SetTranslator(translator)
    translatorRegistered = true
    WOWTR_DialogueUIBridgeActive = true
    return true
end

-- ----------------------------------------------------------------------------
-- 3. Butonlar: ortak tooltip/UI çeviri ve eksik metin kayıt akışı
-- ----------------------------------------------------------------------------
local function TranslateUIObject(obj, context)
    if not (obj and obj.GetText and ST_CheckAndReplaceTranslationTextUI and TT_PS
        and QTR_PS and QTR_PS.dialogueui ~= "0" and QTR_PS.active ~= "0") then
        return false
    end
    local original = obj:GetText()
    ST_CheckAndReplaceTranslationTextUI(obj, true, context, GetTRFont())
    return obj:GetText() ~= original
end

local uiLabelFontString
local function TranslateUILabel(text, context)
    if not text or not DUIQuestFrame then return text end
    if not uiLabelFontString then
        uiLabelFontString = DUIQuestFrame:CreateFontString(nil, "ARTWORK")
        uiLabelFontString:SetFont(GetTRFont(), 12)
        uiLabelFontString:Hide()
    end
    uiLabelFontString:SetText(text)
    TranslateUIObject(uiLabelFontString, context)
    return uiLabelFontString:GetText()
end

local function TranslateButtonLabel(btn, bigPadding)
    -- Quest titles and gossip choices have their own translation databases.
    if btn.type == "gossip" or btn.type == "availableQuest" or btn.type == "activeQuest" then return end
    local label = btn.Name or (btn.Content and btn.Content.Name)
    if TranslateUIObject(label, "DialogueUI:Button") and btn.Layout then
        btn:Layout(bigPadding)
    end
end

local function HookButtonSetText(btn)
    if not btn or btn.__wowtr_btntext_hooked or not btn.SetButtonText then return end
    local originalSetButtonText = btn.SetButtonText
    btn.SetButtonText = function(self, name, bigPadding)
        originalSetButtonText(self, name, bigPadding)
        self.__wowtr_bigPadding = bigPadding
        TranslateButtonLabel(self, bigPadding)
    end
    btn.__wowtr_btntext_hooked = true
end

local function UpdateSingleButtonText(btn)
    if not btn then return end
    HookButtonSetText(btn)
    TranslateButtonLabel(btn, btn.__wowtr_bigPadding)
end

local function RefreshAllActionButtons()
    if not (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then return end
    if DUIQuestFrame then
        UpdateSingleButtonText(DUIQuestFrame.AcceptButton)
        UpdateSingleButtonText(DUIQuestFrame.ExitButton)
        if DUIQuestFrame.optionButtonPool then
            pcall(function()
                for btn in DUIQuestFrame.optionButtonPool:EnumerateActive() do
                    UpdateSingleButtonText(btn)
                end
            end)
        end
    end
end

-- ----------------------------------------------------------------------------
-- 4. Sohbet (Gossip) Çeviri Fonksiyonları (C_GossipInfo & DialogueUI Hook)
-- ----------------------------------------------------------------------------
local function GetTranslatedGossipText(rawText)
    if gossipShowOriginal then return nil end
    if not rawText or rawText == "" then return nil end
    if not (QTR_PS and QTR_PS["gossip"] ~= "0" and QTR_PS["active"] ~= "0") then
        return nil
    end

    local Origin_Text = SafeDetectPlayerName(rawText)
    local Czysty_Text = SafeDeleteSpecialCodes(Origin_Text)
    local Hash = SafeStringHash(Czysty_Text)

    local tr = GS_Gossip and GS_Gossip[Hash]
    if not tr then
        local Czysty_NoLow = string.gsub(Czysty_Text, ' %(low level%)', '')
        local HashNoLow = SafeStringHash(Czysty_NoLow)
        tr = GS_Gossip and GS_Gossip[HashNoLow]
    end

    if tr then
        local res = SafeReplaceCodes(tr)
        res = string.gsub(res, "NEW_LINE", "\n")
        res = string.gsub(res, "$b", "\n")
        res = string.gsub(res, "$B", "\n")
        res = string.gsub(res, "{B}", "\n")
        return res
    end
    return nil
end

local function GetTranslatedGossipOption(rawText)
    if gossipShowOriginal then return nil end
    if not rawText or rawText == "" then return nil end
    if not (QTR_PS and QTR_PS["gossip"] ~= "0" and QTR_PS["active"] ~= "0") then
        return nil
    end

    local GOptionText = SafeDetectPlayerName(rawText, nil, '$N')
    local prefix = ""
    local sufix = ""
    if string.sub(GOptionText, 1, 2) == "|c" then
        prefix = string.sub(GOptionText, 1, 10)
        sufix = "|r"
        GOptionText = string.gsub(GOptionText, prefix, "")
        GOptionText = string.gsub(GOptionText, sufix, "")
    end

    -- DialogueUI numara öneklerini (örn. "1. ") temizle ve sonradan geri ekle
    local numPrefix, cleanText = string.match(GOptionText, "^(%d+%.%s*)(.+)$")
    if numPrefix and cleanText then
        GOptionText = cleanText
    else
        numPrefix = ""
    end

    local Czysty_Text = SafeDeleteSpecialCodes(GOptionText, '$N')
    local OptHash = SafeStringHash(Czysty_Text)
    local tr = QTR_GetGossipOptionTranslation(GOptionText, true)

    if not tr then
        local ueColorText = SafeDeleteSpecialCodes("UE_COLOR:(Quest) " .. GOptionText, '$N')
        local ueColorHash = SafeStringHash(ueColorText)
        if GS_Gossip and GS_Gossip[ueColorHash] then
            local rawTrans = GS_Gossip[ueColorHash]
            tr = string.gsub(rawTrans, "^UE_COLOR:%(.-%)%|r ", "")
        end
    end

    if tr then
        local res = SafeReplaceCodes(tr)
        return prefix .. numPrefix .. res .. sufix
    end
    return nil
end

-- C_GossipInfo API sarmalayıcıları: metni kaynağında Türkçeleştirir.
local function SetupGossipAPISurrogates()
    if C_GossipInfo and C_GossipInfo.GetText and not C_GossipInfo.__wowtr_hooked then
        local orig_GetText = C_GossipInfo.GetText
        originalGossipTextGetter = orig_GetText
        C_GossipInfo.GetText = function(...)
            local text = orig_GetText(...)
            if text and (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then
                local tr = GetTranslatedGossipText(text)
                if tr then return tr end
            end
            return text
        end
        C_GossipInfo.__wowtr_hooked = true
    end

    if C_GossipInfo and C_GossipInfo.GetOptions and not C_GossipInfo.__wowtr_options_hooked then
        local orig_GetOptions = C_GossipInfo.GetOptions
        originalGossipOptionsGetter = orig_GetOptions
        C_GossipInfo.GetOptions = function(...)
            local options = orig_GetOptions(...)
            if options and (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then
                for _, opt in ipairs(options) do
                    if opt.name then
                        local tr = GetTranslatedGossipOption(opt.name)
                        if tr then
                            opt.name = tr
                        end
                    end
                end
            end
            return options
        end
        C_GossipInfo.__wowtr_options_hooked = true
    end
end

-- Expose the untouched API values to the missing-gossip logger.
function WOWTR_GetOriginalDialogueUIGossipData()
    local text = originalGossipTextGetter and originalGossipTextGetter()
    local options = originalGossipOptionsGetter and originalGossipOptionsGetter()
    return text, options
end
-- A compact gossip control sits in the existing margin above the scroll area.
-- The hash is always calculated from the original text, never the displayed TR.
local function SetupDialogueUIGossipControl()
    local frame = DUIQuestFrame
    if not (frame and frame.ScrollFrame and frame.HandleGossip and frame.UseQuestLayout)
        or frame.__wowtr_gossipControl then return end

    local control = CreateFrame("Frame", nil, frame)
    frame.__wowtr_gossipControl = control
    control:SetPoint("BOTTOM", frame.ScrollFrame, "TOP", 0, 8)
    control:SetSize(60, 20)
    control:SetFrameLevel(frame:GetFrameLevel() + 10)
    control:Hide()

    local UpdateControl

    local function CreateLanguageButton(language, xOffset)
        local button = CreateFrame("Button", nil, control)
        button:SetPoint("LEFT", control, "LEFT", xOffset, 0)
        button:SetSize(28, 20)
        button:RegisterForClicks("LeftButtonUp")
        button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
        button:GetHighlightTexture():SetAlpha(0.08)

        local label = button:CreateFontString(nil, "OVERLAY", "DUIFont_Quest_Paragraph")
        label:SetPoint("CENTER")
        label:SetFont(GetTRFont(), 12)
        label:SetText(language)
        button.Label = label

        button:SetScript("OnEnter", function(self)
            if not self.gossipHash then return end
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Gossip-Hash: " .. tostring(self.gossipHash), 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        button:SetScript("OnClick", function()
            if language == "TR" and not button.translationAvailable then return end
            gossipShowOriginal = language == "EN"
            -- Native refresh clears old gossip history and remeasures translated text.
            frame:OnSettingsChanged()
            UpdateControl()
        end)
        return button
    end

    local trButton = CreateLanguageButton("TR", 0)
    local enButton = CreateLanguageButton("EN", 32)
    control.TRButton = trButton
    control.ENButton = enButton

    UpdateControl = function(sourceGetter)
        if sourceGetter then control.sourceGetter = sourceGetter end
        if not (QTR_PS and QTR_PS.active ~= "0" and QTR_PS.dialogueui ~= "0"
            and QTR_PS.gossip ~= "0") or frame.questLayout ~= false then
            control:Hide()
            return
        end
        local getter = control.sourceGetter or originalGossipTextGetter
        local raw = getter and getter()
        if type(raw) ~= "string" or raw == "" then
            control:Hide()
            return
        end
        local normalized = SafeDeleteSpecialCodes(SafeDetectPlayerName(raw))
        local hash = SafeStringHash(normalized)
        if not (GS_Gossip and GS_Gossip[hash]) then
            hash = SafeStringHash(string.gsub(normalized, ' %(low level%)', ''))
        end
        local available = GS_Gossip and GS_Gossip[hash]
        control.gossipHash = hash

        trButton.translationAvailable = available ~= nil
        trButton.gossipHash = hash
        enButton.gossipHash = hash
        trButton:SetEnabled(available ~= nil)
        trButton.Label:SetAlpha(available and not gossipShowOriginal and 1 or 0.55)
        enButton.Label:SetAlpha(gossipShowOriginal and 1 or 0.55)
        control:Show()
    end

    hooksecurefunc(frame, "HandleGossip", function()
        UpdateControl(originalGossipTextGetter)
    end)
    hooksecurefunc(frame, "UseQuestLayout", function(_, isQuest)
        if isQuest then control:Hide() end
    end)
    if frame.HandleQuestGreeting then
        -- Classic quest-giver lists use QUEST_GREETING and GetGreetingText,
        -- even though they look just like gossip. They need the same control.
        hooksecurefunc(frame, "HandleQuestGreeting", function()
            UpdateControl(GetGreetingText)
        end)
    end
end
-- ----------------------------------------------------------------------------
-- 5. DialogueUI Global Mixin Kancaları
-- ----------------------------------------------------------------------------
local function SetupDialogueUIMixinHooks()
    -- XML mixins are copied onto frames at creation time. Hook the live frame,
    -- not just the prototype which it has already copied.
    local DUIDialogBaseMixin = DUIQuestFrame
    if not DUIDialogBaseMixin or DUIDialogBaseMixin.__wowtr_bridge_hooked then return end
    DUIDialogBaseMixin.__wowtr_bridge_hooked = true
    -- Keep DialogueUI's native translator state authoritative. Its data provider
    -- is only called while translation is enabled, including after a left click.
    local originalFormatQuestText = DUIDialogBaseMixin.FormatQuestText
    local originalInsertParagraph = DUIDialogBaseMixin.InsertParagraph
    if originalFormatQuestText and originalInsertParagraph then
        DUIDialogBaseMixin.FormatQuestText = function(self, offsetY, method)
            local previous = self.__wowtr_formattingQuest
            self.__wowtr_formattingQuest = true
            self.__wowtr_questTranslationActive = false
            local result, objectives = originalFormatQuestText(self, offsetY, method)
            self.__wowtr_formattingQuest = previous
            return result, objectives
        end
        DUIDialogBaseMixin.InsertParagraph = function(self, offsetY, text, fontObject)
            if self.__wowtr_formattingQuest and fontObject == "DUIFont_Quest_MultiLanguage"
                and QTR_PS and QTR_PS.dialogueui ~= "0" and QTR_PS.active ~= "0" then
                self.__wowtr_questTranslationActive = true
                -- The native formatter inserts the translated title above the body.
                -- Put it in the header instead; the native title update restores
                -- the English title when the user disables translation.
                local header = self.FrontFrame and self.FrontFrame.Header
                local title = header and header.Title
                if title and QTR_PS.transtitle ~= "0" then
                    title:SetText(text)
                    if title:GetNumLines() > 1 then
                        title:SetFontObject("DUIFont_Quest_Title_16")
                        if title:GetNumLines() > 1 then
                            title:SetFontObject("DUIFont_Quest_Paragraph")
                        end
                    end
                    return offsetY
                end
            end
            return originalInsertParagraph(self, offsetY, text, fontObject)
        end
    end

    -- Progress objectives are a multiline InsertText block, not quest paragraphs.
    -- Translate each bullet independently so hashes and $1/$2 counters match the
    -- existing Collections:QuestObjective UI translations and missing-text log.
    local originalProgress = DUIDialogBaseMixin.HandleQuestProgress
    local originalInsertText = DUIDialogBaseMixin.InsertText
    if originalProgress and originalInsertText then
        DUIDialogBaseMixin.HandleQuestProgress = function(self, ...)
            self.__wowtr_formattingProgress = true
            local result = originalProgress(self, ...)
            self.__wowtr_formattingProgress = nil
            return result
        end
        DUIDialogBaseMixin.InsertText = function(self, offsetY, text, fontObject)
            if self.__wowtr_formattingProgress and self.__wowtr_questTranslationActive
                and type(text) == "string" then
                text = string.gsub(text, "[^\r\n]+", function(line)
                    if string.match(line, "^%s*%-%s+") then
                        return TranslateUILabel(line, "Collections:QuestObjective")
                    end
                    return line
                end)
            end
            return originalInsertText(self, offsetY, text, fontObject)
        end
    end

    -- Use the theme's normal paragraph appearance in translation-only mode.
    -- Native FormatDualParagraph still supplies isTranslation flags for TTS.
    local originalAcquireLeftFontString = DUIDialogBaseMixin.AcquireLeftFontString
    if originalAcquireLeftFontString then
        DUIDialogBaseMixin.AcquireLeftFontString = function(self, fontObject, ...)
            if fontObject == "DUIFont_Quest_MultiLanguage"
                and QTR_PS and QTR_PS.dialogueui ~= "0" and QTR_PS.active ~= "0"
                and not (DialogueUI_DB and DialogueUI_DB.TranslatorShowOriginalText) then
                fontObject = "DUIFont_Quest_Paragraph"
            end
            return originalAcquireLeftFontString(self, fontObject, ...)
        end
    end

    -- 4. Karşılama metni kancası (Gossip)
    if DUIDialogBaseMixin and DUIDialogBaseMixin.FormatParagraph and not DUIDialogBaseMixin.__wowtr_hooked then
        local orig_FormatParagraph = DUIDialogBaseMixin.FormatParagraph
        DUIDialogBaseMixin.FormatParagraph = function(self, offsetY, text, ttsFlag)
            if text and (ttsFlag == 0 or ttsFlag == nil) and (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then
                local npcPrefix, mainText = string.match(text, "^(.-:%s+)(.+)$")
                if npcPrefix and mainText then
                    local tr = GetTranslatedGossipText(mainText)
                    if tr then text = npcPrefix .. tr end
                else
                    local tr = GetTranslatedGossipText(text)
                    if tr then text = tr end
                end
            end
            return orig_FormatParagraph(self, offsetY, text, ttsFlag)
        end
        DUIDialogBaseMixin.__wowtr_hooked = true
    end

    -- 5. Alt başlıklar da ortak tooltip/UI veritabanını kullanır.
    if DUIDialogBaseMixin and DUIDialogBaseMixin.AcquireAndSetSubHeader and not DUIDialogBaseMixin.__wowtr_subheader_hooked then
        local orig_AcquireSubHeader = DUIDialogBaseMixin.AcquireAndSetSubHeader
        DUIDialogBaseMixin.AcquireAndSetSubHeader = function(self, text)
            text = TranslateUILabel(text, "DialogueUI:SubHeader")
            return orig_AcquireSubHeader(self, text)
        end
        DUIDialogBaseMixin.__wowtr_subheader_hooked = true
    end

    -- 6. Buton oluşturma fabrikaları kancası (AcceptButton / ExitButton)
    if DUIDialogBaseMixin and DUIDialogBaseMixin.AcquireAcceptButton and not DUIDialogBaseMixin.__wowtr_acq_accept_hooked then
        local orig_AcquireAccept = DUIDialogBaseMixin.AcquireAcceptButton
        DUIDialogBaseMixin.AcquireAcceptButton = function(self, enableHotkey)
            local btn = orig_AcquireAccept(self, enableHotkey)
            if btn then
                HookButtonSetText(btn)
                UpdateSingleButtonText(btn)
            end
            return btn
        end
        DUIDialogBaseMixin.__wowtr_acq_accept_hooked = true
    end

    if DUIDialogBaseMixin and DUIDialogBaseMixin.AcquireExitButton and not DUIDialogBaseMixin.__wowtr_acq_exit_hooked then
        local orig_AcquireExit = DUIDialogBaseMixin.AcquireExitButton
        DUIDialogBaseMixin.AcquireExitButton = function(self)
            local btn = orig_AcquireExit(self)
            if btn then
                HookButtonSetText(btn)
                UpdateSingleButtonText(btn)
            end
            return btn
        end
        DUIDialogBaseMixin.__wowtr_acq_exit_hooked = true
    end

    -- 7. Seçenek butonları kancası (Gossip Options)
    if DUIDialogOptionButtonMixin and DUIDialogOptionButtonMixin.SetGossip and not DUIDialogOptionButtonMixin.__wowtr_hooked then
        local orig_SetGossip = DUIDialogOptionButtonMixin.SetGossip
        DUIDialogOptionButtonMixin.SetGossip = function(self, data, hotkey)
            if data and data.name and (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then
                local tr = GetTranslatedGossipOption(data.name)
                if tr then data.name = tr end
            end
            return orig_SetGossip(self, data, hotkey)
        end
        DUIDialogOptionButtonMixin.__wowtr_hooked = true
    end

    if DUIDialogOptionButtonMixin and DUIDialogOptionButtonMixin.SetGossipHint and not DUIDialogOptionButtonMixin.__wowtr_hint_hooked then
        local orig_SetGossipHint = DUIDialogOptionButtonMixin.SetGossipHint
        DUIDialogOptionButtonMixin.SetGossipHint = function(self, data, hotkey)
            if data and data.name and (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0") then
                local tr = GetTranslatedGossipOption(data.name)
                if tr then data.name = tr end
            end
            return orig_SetGossipHint(self, data, hotkey)
        end
        DUIDialogOptionButtonMixin.__wowtr_hint_hooked = true
    end

    -- 8. Görev seçenek butonları kancası (Gossip içindeki görev listesi butonları)
    if DUIDialogOptionButtonMixin and DUIDialogOptionButtonMixin.SetQuest and not DUIDialogOptionButtonMixin.__wowtr_quest_hooked then
        local orig_SetQuest = DUIDialogOptionButtonMixin.SetQuest
        DUIDialogOptionButtonMixin.SetQuest = function(self, questInfo, hotkey)
            if not gossipShowOriginal and questInfo and questInfo.questID
                and (QTR_PS and QTR_PS["dialogueui"] ~= "0" and QTR_PS["active"] ~= "0"
                    and QTR_PS["transtitle"] ~= "0") then
                local strID = tostring(questInfo.questID)
                local qData = QTR_QuestData and QTR_QuestData[strID]
                if qData and qData["Title"] then
                    local clean = CleanQuestText(qData["Title"])
                    if clean and clean ~= "" then
                        -- Keep the source record English: gossip providers may
                        -- reuse it when the page is rebuilt after a language click.
                        local translatedInfo = {}
                        for key, value in pairs(questInfo) do
                            translatedInfo[key] = value
                        end
                        translatedInfo.title = clean
                        questInfo = translatedInfo
                    end
                end
            end
            return orig_SetQuest(self, questInfo, hotkey)
        end
        DUIDialogOptionButtonMixin.__wowtr_quest_hooked = true
    end

    -- 9. Buton metinleri ve boyutlandırma kancası (DUIDialogOptionButtonMixin & mevcut butonlar)
    HookButtonSetText(DUIDialogOptionButtonMixin)

    if DUIQuestFrame then
        HookButtonSetText(DUIQuestFrame.AcceptButton)
        HookButtonSetText(DUIQuestFrame.ExitButton)
    end

    -- 10. Pencere açılma / güncelleme secure hook'ları
    pcall(function()
        hooksecurefunc(DUIDialogBaseMixin, "HandleQuestDetail", RefreshAllActionButtons)
        hooksecurefunc(DUIDialogBaseMixin, "HandleQuestProgress", RefreshAllActionButtons)
        hooksecurefunc(DUIDialogBaseMixin, "HandleQuestComplete", RefreshAllActionButtons)
        hooksecurefunc(DUIDialogBaseMixin, "HandleGossip", RefreshAllActionButtons)
        hooksecurefunc(DUIDialogBaseMixin, "HandleQuestGreeting", RefreshAllActionButtons)
        hooksecurefunc(DUIDialogBaseMixin, "ShowUI", RefreshAllActionButtons)
    end)
end

-- DialogueUI consumes NPC events directly, bypassing Blizzard chat filters.
-- Translate before its OnEvent formats emotes, measures text and stores history.
-- Do not call BB_ChatFilter here: it also prints to chat and queues speech bubbles.
local function TranslateNPCMessage(text, name, target)
    -- NPC events commonly pass an empty target instead of nil.
    if target == "" then target = nil end
    if type(text) ~= "string" or type(name) ~= "string" then return text end
    if not (QTR_PS and QTR_PS.dialogueui ~= "0" and QTR_PS.active ~= "0"
        and BB_PM and BB_PM.active == "1" and BB_PM["chat-tr"] == "1") then
        return text
    end
    local original = string.match(text, "^%s*(.-)%s*$")
    local normalized = SafeDeleteSpecialCodes(SafeDetectPlayerName(original, target))
    local hash = SafeStringHash(normalized)
    local translated = (BB_Bubbles and BB_Bubbles[hash]) or (MF_Hash and MF_Hash[hash])
    if not translated then return text end
    translated = SafeReplaceCodes(translated, target)
    -- DialogueUI itself expands %s in emotes; expand here for other NPC events too.
    translated = string.gsub(translated, "%%s", function() return name end)
    translated = string.gsub(translated, "^%%o%s*", "")
    return translated
end

local function SetupDialogueUIChat()
    if not (DUIQuestFrame and DUIQuestFrame.GetChildren) then return end
    for _, child in ipairs({DUIQuestFrame:GetChildren()}) do
        -- The chat frame is anonymous; identify its specific interface.
        if child.AddMessage and child.ListenEvents and child.OnEvent and not child.__wowtr_chat_hooked then
            local originalOnEvent = child.OnEvent
            child.OnEvent = function(self, event, text, name, language, channel, target, ...)
                if event and string.sub(event, 1, 9) == "CHAT_MSG_" then
                    if CanAccessDialogueValue(text) and CanAccessDialogueValue(name)
                        and CanAccessDialogueValue(target) then
                        local ok, translated = pcall(TranslateNPCMessage, text, name, target)
                        if ok then text = translated end
                    end
                end
                return originalOnEvent(self, event, text, name, language, channel, target, ...)
            end
            -- ListenEvents may already have installed the old method as a script.
            if child:GetScript("OnEvent") == originalOnEvent then
                child:SetScript("OnEvent", child.OnEvent)
            end
            child.__wowtr_chat_hooked = true
        end
    end
end

-- DialogueUI's item tooltips are anonymous custom frames, not GameTooltip.
-- Its public processor runs after item data is populated (including async updates)
-- and relayouts the tooltip when we return true. Keep each line's existing color.
local itemTooltipProcessorRegistered = false
local function TranslateDialogueUIItemTooltip(tooltip, itemID)
    if not (QTR_PS and QTR_PS.dialogueui ~= "0" and QTR_PS.active ~= "0"
        and ST_PM and ST_PM.active == "1" and ST_PM.item ~= "0"
        and ST_CheckAndReplaceTranslationText and tooltip and tooltip.fontStrings) then
        return false
    end
    local changed = false
    local prefix = itemID and ("i" .. tostring(itemID)) or "DialogueUI:Item"
    for index = 1, tooltip.numFontStrings or 0 do
        local line = tooltip.fontStrings[index]
        if line and line.GetText then
            local original = line:GetText()
            if index == 1 then
                -- Use the same optional item-title database as normal tooltips.
                local title = ST_TooltipsID and ST_TooltipsID[prefix]
                if title and ST_PM.transtitle == "1" and original then
                    line:SetText(SafeReplaceCodes(title) .. " ")
                    ApplyFontToDUIObject(line)
                end
            else
                ST_CheckAndReplaceTranslationText(line, true, prefix, GetTRFont())
            end
            changed = changed or line:GetText() ~= original
        end
    end
    return changed
end

local function SetupDialogueUIItemTooltips()
    if not itemTooltipProcessorRegistered and DialogueUIAPI
        and DialogueUIAPI.AddItemTooltipProcessorExternal then
        DialogueUIAPI.AddItemTooltipProcessorExternal(TranslateDialogueUIItemTooltip)
        itemTooltipProcessorRegistered = true
    end
end

-- Quest metadata uses the same unobtrusive theme font as the gossip control.
local function SetupDialogueUIQuestID()
    local frame = DUIQuestFrame
    if not (frame and frame.FrontFrame and frame.UseQuestLayout)
        or frame.__wowtr_questIDLabel then return end
    local label = frame.FrontFrame:CreateFontString(nil, "OVERLAY", "DUIFont_Quest_Paragraph")
    frame.__wowtr_questIDLabel = label
    label:SetPoint("TOP", frame, "TOP", 0, -18)
    label:SetFont(GetTRFont(), 12)
    label:SetAlpha(0.75)
    label:Hide()

    local function UpdateQuestID()
        local questID = frame.questID
        if frame.questLayout and CanAccessDialogueValue(questID)
            and type(questID) == "number" and questID > 0
            and QTR_PS and QTR_PS.dialogueui ~= "0" then
            label:SetText("Quest ID: " .. tostring(questID))
            label:Show()
        else
            label:Hide()
        end
    end
    hooksecurefunc(frame, "UseQuestLayout", UpdateQuestID)
    UpdateQuestID()
end

-- ----------------------------------------------------------------------------
-- 6. Ana Başlatma Fonksiyonu
-- ----------------------------------------------------------------------------
function WOWTR_InitDialogueUI()
    -- DialogueUI yüklü değilse işlem yapma
    if not (DUIQuestFrame or DialogueUIAPI or (C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("DialogueUI"))) then
        return false
    end

    -- DialogueUI defaults this setting to true before WoWTR loads. Migrate
    -- once, then preserve subsequent choices made with its translation button.
    if QTR_PS and DialogueUI_DB and not QTR_PS.dialogueuiOriginalTextInitialized then
        DialogueUI_DB["TranslatorShowOriginalText"] = false
        QTR_PS.dialogueuiOriginalTextInitialized = true
    end

    SetupDialogueUIFonts()
    RegisterDialogueUITranslator()
    SetupGossipAPISurrogates()
    SetupDialogueUIMixinHooks()
    SetupDialogueUIChat()
    SetupDialogueUIGossipControl()
    SetupDialogueUIQuestID()
    SetupDialogueUIItemTooltips()
    RefreshAllActionButtons()

    bridgeInitialized = true
    WOWTR_DialogueUIBridgeActive = true
    return true
end

-- Dosya yüklendiğinde DialogueUI zaten bellekteyse hemen devreye gir
C_Timer.After(0.05, function()
    WOWTR_InitDialogueUI()
end)

-- Olay dinleyicisi: DialogueUI sonradan yüklense bile köprüyü kur
local bridgeFrame = CreateFrame("Frame")
bridgeFrame:RegisterEvent("PLAYER_LOGIN")
bridgeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bridgeFrame:RegisterEvent("ADDON_LOADED")
bridgeFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DialogueUI" then
        WOWTR_InitDialogueUI()
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        WOWTR_InitDialogueUI()
        RefreshAllActionButtons()
    end
end)
