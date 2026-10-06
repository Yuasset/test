local W = WoWTRV
local labels = {
    {"enabled", "WoWTR etkin"}, {"quests", "Görev kabulü, günlüğü ve teslimi"},
    {"gossip", "NPC diyalogları ve seçenekleri"}, {"books", "Kitap ve mektuplar"},
    {"tooltips", "Eşya ve büyü açıklamaları"}, {"bubbles", "NPC konuşmaları ve konuşma balonları"},
    {"subtitles", "İstemcinin sağladığı sinematik altyazıları"}, {"tutorials", "Öğretici metinleri"},
    {"questTitles", "Okuma panelinde Türkçe görev başlığı"}, {"ui", "Görev ekranı düğme ve başlıkları"}, {"saveMissing", "Bulunamayan metinleri kaydet"},
    {"minimap", "Mini harita düğmesini göster"}, {"sellGrey", "Satıcıda gri eşyaları otomatik sat"},
    {"combatLog", "Zindan ve raidlerde savaş kaydı"},
}

function W.Changed(key)
    if key == "enabled" then W.Restore()
    elseif not W.db[key] then W.Restore(key) end
    if W.reader then W.RenderQuest(W.questContext) end
    if W.minimap then if W.db.minimap then W.minimap:Show() else W.minimap:Hide() end end
    if W.CheckCombatLog then W.CheckCombatLog() end
    W.Later(0.05, function() W.Gossip(); W.Book(); W.Tutorials() end, "settingsRefresh")
end

function W.ShowOptions()
    if not W.options then
        local frame = W.NewFrame("Frame", "WoWTRVanillaOptions", UIParent)
        frame:SetWidth(455); frame:SetHeight(555); frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("DIALOG"); W.Backdrop(frame)
        frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", function() this:StartMoving() end)
        frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        local title = W.Text(frame, 19, "WoWTR · OctoWoW")
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -17)
        local close = W.Button(frame, "X", 25, function() W.options:Hide() end)
        close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
        frame.checkboxes = {}
        for index, option in ipairs(labels) do
            local key = option[1]
            local box = W.NewFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
            box:SetWidth(25); box:SetHeight(25)
            box:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -48 - (index - 1) * 27)
            local label = W.Text(frame, 13, option[2])
            label:SetPoint("LEFT", box, "RIGHT", 7, 0)
            box:SetScript("OnClick", function()
                W.db[key] = this:GetChecked() and true or false
                W.Changed(key)
            end)
            frame.checkboxes[key] = box
        end
        frame.fontLabel = W.Text(frame, 13, "")
        frame.fontLabel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 81)
        local smaller = W.Button(frame, "−", 35, function()
            W.db.fontSize = math.max(10, W.db.fontSize - 1); W.UpdateOptions(); W.Changed("fontSize")
        end)
        smaller:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 190, 74)
        local larger = W.Button(frame, "+", 35, function()
            W.db.fontSize = math.min(22, W.db.fontSize + 1); W.UpdateOptions(); W.Changed("fontSize")
        end)
        larger:SetPoint("LEFT", smaller, "RIGHT", 8, 0)
        local diagnostic = W.Button(frame, "Tanı kaydı", 115, W.ShowLog)
        diagnostic:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 39)
        local status = W.Button(frame, "Durum", 80, W.Status)
        status:SetPoint("LEFT", diagnostic, "RIGHT", 8, 0)
        local original = W.Button(frame, "EN / TR", 85, function()
            W.readerEnglish = not W.readerEnglish; W.readerDismissed = false
            W.RenderQuest(W.questContext)
        end)
        original:SetPoint("LEFT", status, "RIGHT", 8, 0)
        local footer = W.Text(frame, 11, "Çevirisi bulunmayan metinler özgün dilinde kalır. /wowtr")
        footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 15)
        W.options = frame
        if UISpecialFrames then table.insert(UISpecialFrames, "WoWTRVanillaOptions") end
        frame:Hide()
    end
    W.UpdateOptions()
    if W.options:IsShown() then W.options:Hide() else W.options:Show() end
end

function W.UpdateOptions()
    if not W.options then return end
    for key, box in pairs(W.options.checkboxes) do box:SetChecked(W.db[key]) end
    W.options.fontLabel:SetText("Okuma yazısı: " .. W.db.fontSize)
end

function W.Status()
    local errors = table.getn(WoWTRVanillaLog.errors)
    local missing = 0
    for _ in pairs(WoWTRVanillaLog.missing) do missing = missing + 1 end
    W.Message(W.version .. " · " .. tostring(W.DataStats.quests or 0) .. " görev · " .. errors .. " hata · " .. missing .. " eksik metin")
    if W.questContext then
        local context = W.questContext
        W.Message("Görev: " .. context.title .. " · ID: " .. tostring(context.resolvedID or "belirsiz") .. " · " .. tostring(context.resolution))
        if context.resolution == "ambiguous" then
            local ids = {}
            for _, candidate in ipairs(W.Titles[context.title] or {}) do table.insert(ids, tostring(candidate[1])) end
            W.Message("Aday ID'ler: " .. table.concat(ids, ", ") .. ". Doğru ID için /wowtr id NUMARA")
        end
    end
end

function W.LogText()
    local build, number
    if GetBuildInfo then build, number = GetBuildInfo() end
    local lines = {"WoWTR " .. W.version, "Client: " .. tostring(build) .. " / " .. tostring(number), "Lua: " .. tostring(_VERSION)}
    for _, error in ipairs(WoWTRVanillaLog.errors) do table.insert(lines, error.time .. " " .. error.message) end
    if W.questContext then
        local context = W.questContext
        table.insert(lines, "Quest: " .. context.title .. " / " .. tostring(context.resolvedID) .. " / " .. tostring(context.resolution))
    end
    local keys = {}
    for key in pairs(WoWTRVanillaLog.missing) do table.insert(keys, key) end
    table.sort(keys)
    for _, key in ipairs(keys) do table.insert(lines, "MISSING " .. key .. "\n" .. WoWTRVanillaLog.missing[key]) end
    return table.concat(lines, "\n\n")
end

function W.ShowLog()
    if not W.logFrame then
        local frame = W.NewFrame("Frame", "WoWTRVanillaLogWindow", UIParent)
        frame:SetWidth(590); frame:SetHeight(400); frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        frame:SetFrameStrata("DIALOG"); W.Backdrop(frame)
        local label = W.Text(frame, 15, "Tanı kaydı · Ctrl+A, Ctrl+C ile kopyalayın")
        label:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -18)
        local close = W.Button(frame, "X", 25, function() W.logFrame:Hide() end)
        close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
        local scroll = W.NewFrame("ScrollFrame", "WoWTRVanillaLogScroll", frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -52)
        scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -38, 20)
        local edit = W.NewFrame("EditBox", "WoWTRVanillaLogEdit", scroll)
        edit:SetWidth(525); edit:SetHeight(310); edit:SetFont(W.font, 12)
        edit:SetMultiLine(true); edit:SetAutoFocus(false)
        edit:SetScript("OnEscapePressed", function() W.logFrame:Hide() end)
        edit:SetScript("OnTextChanged", function() this:GetParent():UpdateScrollChildRect() end)
        scroll:SetScrollChild(edit)
        frame.edit = edit; W.logFrame = frame
        if UISpecialFrames then table.insert(UISpecialFrames, "WoWTRVanillaLogWindow") end
    end
    W.logFrame.edit:SetText(W.LogText())
    W.logFrame:Show(); W.logFrame.edit:SetFocus(); W.logFrame.edit:HighlightText()
end

function W.CreateMinimap()
    if not Minimap then return end
    local button = W.NewFrame("Button", "WoWTRVanillaMinimapButton", Minimap)
    button:SetWidth(28); button:SetHeight(28); button:SetFrameStrata("MEDIUM")
    button:SetNormalTexture("Interface\\Icons\\INV_Misc_Book_09")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp"); button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function() W.ShowOptions() end)
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT"); GameTooltip:SetText("WoWTR · Türkçe Yama")
        GameTooltip:AddLine("Ayarlar: tıkla · Konum: sürükle", 1, 1, 1); GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", function() W.minimapDragging = true end)
    button:SetScript("OnDragStop", function() W.minimapDragging = false end)
    W.minimap = button; W.PositionMinimap()
    if not W.db.minimap then button:Hide() end
end

function W.PositionMinimap()
    if not W.minimap then return end
    local radians = (W.db.minimapAngle or 225) * math.pi / 180
    W.minimap:ClearAllPoints()
    W.minimap:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * 80, math.sin(radians) * 80)
end

function W.MinimapDrag()
    if not W.minimapDragging or not Minimap or not GetCursorPosition then return end
    local x, y = GetCursorPosition()
    local centerX, centerY = Minimap:GetCenter(); local scale = Minimap:GetEffectiveScale()
    if centerX and centerY then
        x = x / scale - centerX; y = y / scale - centerY
        local angle
        if math.atan2 then angle = math.atan2(y, x)
        elseif x == 0 then angle = y >= 0 and math.pi / 2 or -math.pi / 2
        else angle = math.atan(y / x); if x < 0 then angle = angle + math.pi end end
        W.db.minimapAngle = angle * 180 / math.pi; W.PositionMinimap()
    end
end

function W.Slash(message)
    local _, _, command, value = string.find(W.Trim(message), "^(%S+)%s*(.-)$")
    command = string.lower(command or "ayar")
    if command == "durum" or command == "status" then W.Status()
    elseif command == "log" then W.ShowLog()
    elseif command == "id" then W.BindQuest(value)
    elseif command == "on" or command == "ac" then W.db.enabled = true; W.Changed("enabled"); W.Message("Etkin.")
    elseif command == "off" or command == "kapat" then W.db.enabled = false; W.Changed("enabled"); W.Message("Devre dışı.")
    elseif command == "resetlog" then WoWTRVanillaLog = {errors={}, missing={}}; W.session = {}; W.Message("Tanı kayıtları temizlendi.")
    else W.ShowOptions() end
end
