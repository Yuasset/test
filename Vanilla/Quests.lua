local W = WoWTRV

local function cleanObjective(text)
    text = W.PlayerTokens(W.Trim(text))
    text = string.gsub(text, "<name>", "$N")
    text = string.gsub(text, "<class>", "$C")
    text = string.gsub(text, "<race>", "$R")
    return string.gsub(text, "%s+", " ")
end

function W.ResolveQuest(title, objectives, explicitID)
    local id = tonumber(explicitID)
    if id and id > 0 then return id, "api" end
    title = W.Trim(title)
    local objective = cleanObjective(objectives or "")
    local binding = W.db.questBindings[title .. "\n" .. objective]
    if binding then return binding, "manual" end
    local candidates = W.Titles[title]
    if not candidates and pfDB and pfDB.quests then
        candidates = {}
        for questID, quest in pairs(pfDB.quests) do
            if type(quest) == "table" and quest[1] == title then table.insert(candidates, {tonumber(questID), ""}) end
        end
        if table.getn(candidates) == 0 then candidates = nil end
    end
    if not candidates then return nil, "unknown" end
    local matched, count, seen = nil, 0, {}
    if objective ~= "" then
        for _, candidate in ipairs(candidates) do
            local prefix = cleanObjective(candidate[2])
            if prefix ~= "" and string.sub(objective, 1, string.len(prefix)) == prefix and not seen[candidate[1]] then
                matched = candidate[1]; count = count + 1; seen[matched] = true
            end
        end
        if count == 1 then return matched, "objective" end
        if count > 1 then return nil, "ambiguous" end
    end
    local only, unique = nil, 0
    seen = {}
    for _, candidate in ipairs(candidates) do
        if not seen[candidate[1]] then only = candidate[1]; unique = unique + 1; seen[only] = true end
    end
    if unique == 1 then return only, "title" end
    return nil, "ambiguous"
end

function W.CreateReader()
    if W.reader then return end
    local frame = W.NewFrame("Frame", "WoWTRVanillaReader", UIParent)
    frame:SetWidth(340); frame:SetHeight(425); frame:SetFrameStrata("HIGH")
    W.Backdrop(frame)
    frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    if frame.SetClampedToScreen then frame:SetClampedToScreen(true) end
    frame:Hide()
    frame.title = W.Text(frame, 16, "WoWTR")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)
    frame.title:SetWidth(255); frame.title:SetJustifyH("LEFT")
    frame.status = W.Text(frame, 11, "")
    frame.status:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -43)
    frame.status:SetWidth(310); frame.status:SetJustifyH("LEFT")
    local close = W.Button(frame, "X", 25, function() W.reader:Hide(); W.readerDismissed = true end)
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
    local language = W.Button(frame, "EN / TR", 75, function()
        W.readerEnglish = not W.readerEnglish
        W.RenderQuest(W.questContext)
    end)
    language:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 12)
    local settings = W.Button(frame, "Ayarlar", 80, function() W.ShowOptions() end)
    settings:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 12)
    local scroll = W.NewFrame("ScrollFrame", "WoWTRVanillaReaderScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -65)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -35, 43)
    local child = W.NewFrame("Frame", "WoWTRVanillaReaderChild", scroll)
    child:SetWidth(287); child:SetHeight(300)
    local body = W.Text(child, 14, "")
    body:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
    body:SetWidth(287); body:SetJustifyH("LEFT"); body:SetJustifyV("TOP")
    scroll:SetScrollChild(child)
    frame.body = body; frame.scroll = scroll; frame.child = child
    W.reader = frame
end

local function block(label, text)
    if type(text) ~= "string" or text == "" then return "" end
    return "|cffffd100" .. label .. "|r\n" .. W.Format(text) .. "\n\n"
end

function W.RenderQuest(context)
    if not W.Active("quests") or not context or context.title == "" then
        if W.reader then W.reader:Hide() end
        return
    end
    W.CreateReader()
    local id, resolution = W.ResolveQuest(context.title, context.objectives, context.id)
    context.resolvedID = id; context.resolution = resolution
    local translation = id and W.Quests[tostring(id)]
    local body = ""
    if translation and not W.readerEnglish then
        W.reader.title:SetText(W.db.questTitles and W.Format(translation.Title or context.title) or context.title)
        if context.stage == "progress" then body = block("İlerleme", translation.Progress)
        elseif context.stage == "reward" then body = block("Tamamlama", translation.Completion)
        else body = block("Açıklama", translation.Description) .. block("Hedefler", translation.Objectives) end
        if body == "" then body = block("Özgün metin", context.description) .. block("Hedefler", context.objectives) end
        W.reader.status:SetText("Türkçe · Görev ID: " .. id)
    else
        W.reader.title:SetText(context.title)
        body = block("Özgün metin", context.description) .. block("Hedefler", context.objectives)
        local message = "Çeviri veritabanında bulunamadı"
        if translation then message = "İngilizce görünüm"
        elseif resolution == "ambiguous" then message = "Aynı adlı görevler: ID seçimi gerekiyor"
        elseif not id then message = "Görev ID'si belirlenemedi" end
        W.reader.status:SetText(message .. (id and (" · " .. id) or ""))
        if not translation then W.Missing("quest", id or context.title, context.title .. "\n" .. context.description .. "\n" .. context.objectives) end
    end
    W.reader.body:SetFont(W.font, W.db.fontSize)
    W.reader.body:SetText(body)
    local height = W.reader.body.GetStringHeight and W.reader.body:GetStringHeight() or W.reader.body:GetHeight()
    W.reader.child:SetHeight(math.max(300, (height or 300) + 20))
    if W.reader.scroll.SetVerticalScroll then W.reader.scroll:SetVerticalScroll(0) end
    if W.readerAnchor ~= context.parent then
        W.reader:ClearAllPoints()
        W.reader:SetPoint("TOPLEFT", context.parent or UIParent, "TOPRIGHT", -10, -18)
        W.readerAnchor = context.parent
    end
    if not W.readerDismissed then W.reader:Show() end
end

function W.QuestEvent(stage)
    local id
    if type(GetQuestID) == "function" then id = GetQuestID() end
    local title = GetTitleText and GetTitleText() or ""
    local description = ""
    if stage == "progress" then description = GetProgressText and GetProgressText() or ""
    elseif stage == "reward" then description = GetRewardText and GetRewardText() or ""
    else description = GetQuestText and GetQuestText() or "" end
    local objective = GetObjectiveText and GetObjectiveText() or ""
    W.questContext = {title = title or "", description = description or "", objectives = objective or "", id = id, stage = stage, parent = QuestFrame}
    W.readerDismissed = false
    W.Later(0.08, function() W.RenderQuest(W.questContext) end, "quest")
end

function W.QuestLog()
    if not W.Active("quests") or not QuestLogFrame or not QuestLogFrame:IsShown() then return end
    if QuestFrame and QuestFrame:IsShown() then return end
    local selected = GetQuestLogSelection and GetQuestLogSelection() or 0
    if selected <= 0 then return end
    local title, level, tag, header, collapsed, complete, frequency, id = GetQuestLogTitle(selected)
    if header or not title then return end
    local description, objectives = GetQuestLogQuestText()
    local previous = W.questContext
    if not previous or previous.title ~= title or previous.description ~= description or previous.parent ~= QuestLogFrame then W.readerDismissed = false end
    W.questContext = {title=title, description=description or "", objectives=objectives or "", id=id, stage="log", parent=QuestLogFrame}
    W.RenderQuest(W.questContext)
end

function W.InitQuests()
    local function refresh() W.Later(0.08, W.QuestLog, "questLog") end
    for _, name in ipairs({"QuestLog_Update", "QuestLog_UpdateQuestDetails", "QuestLogTitleButton_OnClick", "QuestLog_SetSelection"}) do W.Hook(name, refresh) end
    for _, frame in ipairs({QuestFrame or false, QuestLogFrame or false}) do
        if frame and frame.GetScript then
            local old = frame:GetScript("OnHide")
            frame:SetScript("OnHide", function()
                if old then old() end
                if W.reader then W.reader:Hide() end
                W.readerAnchor = nil
            end)
        end
    end
end

function W.BindQuest(id)
    id = tonumber(id)
    local context = W.questContext
    if not context or not id or not W.Quests[tostring(id)] then
        W.Message("Görev penceresini açıp veritabanındaki ID ile /wowtr id 123 yazın.")
        return
    end
    local candidates = W.Titles[context.title] or {}
    local valid = false
    for _, candidate in ipairs(candidates) do if candidate[1] == id then valid = true end end
    if not valid then W.Message("Bu ID, açık görevin İngilizce adıyla eşleşmiyor."); return end
    W.db.questBindings[context.title .. "\n" .. cleanObjective(context.objectives)] = id
    W.readerDismissed = false
    W.RenderQuest(context)
end
