-- WoWTR OctoWoW adapter. Native Vanilla / Lua 5.0; no injected DLL required.
WoWTRV = {
    version = "26.1005-octo.1", PackedDB = {}, DataStats = {},
    modules = {}, timers = {}, originals = setmetatable({}, {__mode = "k"}),
    cache = {}, cacheSize = {}, pending = {}, session = {},
    defaults = {enabled = true, quests = true, gossip = true, books = true, ui = true,
        tooltips = true, bubbles = true, subtitles = true, tutorials = true,
        questTitles = true, fontSize = 14, saveMissing = true,
        minimap = true, minimapAngle = 225, sellGrey = false, combatLog = false},
}
local W = WoWTRV
W.font = "Interface\\AddOns\\WoWTR\\Fonts\\Expressway.ttf"

function W.Capture(...) return arg end
function W.Trim(text)
    return string.gsub(tostring(text or ""), "^%s*(.-)%s*$", "%1")
end
function W.Escape(text)
    return string.gsub(text, "([%%%-%^%$%(%)%.%[%]%*%+%?])", "%%%1")
end
function W.Hash(text)
    if type(text) ~= "string" or text == "" then return 0 end
    local counter, length = 1, string.len(text)
    for i = 1, length, 3 do
        counter = math.mod(counter * 8161, 4294967279)
        counter = counter + string.byte(text, i) * 16776193
        counter = counter + (string.byte(text, i + 1) or (length - i + 256)) * 8372226
        counter = counter + (string.byte(text, i + 2) or (length - i + 256)) * 3932164
    end
    return math.mod(counter, 4294967291)
end
function W.Message(text)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00WoWTR:|r " .. tostring(text)) end
end
function W.Error(label, message)
    local text = label .. ": " .. tostring(message)
    if not WoWTRVanillaLog then WoWTRVanillaLog = {errors = {}, missing = {}} end
    WoWTRVanillaLog.errors = WoWTRVanillaLog.errors or {}
    if W.session[text] then return end
    W.session[text] = true
    local errors = WoWTRVanillaLog.errors
    table.insert(errors, {time = date and date("%Y-%m-%d %H:%M:%S") or "", message = text})
    if table.getn(errors) > 40 then table.remove(errors, 1) end
    W.Message("Uyumluluk hatası kaydedildi. /wowtr durum — " .. text)
end
function W.Protected(label, fn, ...)
    local result = W.Capture(pcall(fn, unpack(arg)))
    if not result[1] then W.Error(label, result[2]); return nil end
    local length = result.n
    for index = 1, length - 1 do result[index] = result[index + 1] end
    result[length] = nil
    result.n = length - 1
    return unpack(result)
end
function W.Later(delay, fn, key)
    if key then
        for _, timer in ipairs(W.timers) do
            if timer.key == key then timer.delay = delay; timer.fn = fn; return end
        end
    end
    table.insert(W.timers, {delay = delay, fn = fn, key = key})
end
function W.Hook(name, after)
    local old = _G[name]
    if type(old) ~= "function" then return false end
    _G[name] = function(...)
        local results = W.Capture(old(unpack(arg)))
        W.Protected(name, after)
        return unpack(results)
    end
    return true
end
function W.Active(module)
    return W.db and W.db.enabled and W.db[module]
end
function W.Lookup(name, hash)
    if not hash or hash == 0 or not W.PackedDB[name] then return nil end
    local cache = W.cache[name]
    if not cache then cache = {}; W.cache[name] = cache; W.cacheSize[name] = 0 end
    if cache[hash] ~= nil then return cache[hash] or nil end
    local bucket = W.PackedDB[name][math.mod(hash, 512) + 1]
    local translation
    if bucket then
        local _, finish = string.find(bucket, "\n" .. string.format("%.0f", hash) .. "\t", 1, true)
        if finish then
            local ending = string.find(bucket, "\n", finish + 1, true)
            local encoded = string.sub(bucket, finish + 1, ending - 1)
            translation = string.gsub(encoded, "\\(.)", function(code)
                if code == "n" then return "\n" elseif code == "r" then return "\r"
                elseif code == "t" then return "\t" else return code end
            end)
        end
    end
    if W.cacheSize[name] >= 2048 then cache = {}; W.cache[name] = cache; W.cacheSize[name] = 0 end
    cache[hash] = translation or false
    W.cacheSize[name] = W.cacheSize[name] + 1
    return translation
end

function W.PlayerTokens(text)
    text = text or ""
    local replacements = {{UnitName("player"), "$N"}, {UnitClass("player"), "$C"}, {UnitRace("player"), "$R"}}
    for _, pair in ipairs(replacements) do
        if pair[1] and pair[1] ~= "" then text = string.gsub(text, W.Escape(pair[1]), pair[2]) end
    end
    return text
end
function W.Normalize(text, numbers)
    text = W.PlayerTokens(tostring(text or ""))
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "\r", "")
    text = string.gsub(text, "\n", "")
    if numbers then text = string.gsub(text, "%d", "") end
    return text
end
function W.Format(text, original)
    text = tostring(text or "")
    local name = UnitName("player") or ""
    local class, race = UnitClass("player") or "", UnitRace("player") or ""
    local classes = {Warrior="Savaşçı", Mage="Büyücü", Rogue="Haydut", Priest="Rahip", Warlock="Karabüyücü", Hunter="Avcı", Paladin="Paladin", Shaman="Şaman", Druid="Druid"}
    local races = {Human="İnsan", Orc="Ork", Dwarf="Cüce", ["Night Elf"]="Gece Elfi", Undead="Ölümsüz", Tauren="Tauren", Gnome="Gnom", Troll="Trol"}
    text = string.gsub(text, "%$[bB]", "\n")
    text = string.gsub(text, "NEW_LINE", "\n")
    text = string.gsub(text, "|n", "\n")
    text = string.gsub(text, "%$[nN]", function() return name end)
    text = string.gsub(text, "%$[cC]", function() return classes[class] or class end)
    text = string.gsub(text, "%$[rR]", function() return races[race] or race end)
    text = string.gsub(text, "YOUR_NAME", function() return name end)
    text = string.gsub(text, "YOUR_CLASS", function() return classes[class] or class end)
    text = string.gsub(text, "YOUR_RACE", function() return races[race] or race end)
    local female = UnitSex and UnitSex("player") == 3
    text = string.gsub(text, "%$[gG]([^:;]+):([^;]+);", function(male, woman) if female then return woman else return male end end)
    text = string.gsub(text, "%$[oO]%(([^;]+);([^%)]+)%)", "%1")
    -- Retail-only atlas/color tags cannot be drawn by the Vanilla font renderer.
    text = string.gsub(text, "|cn[%w_]+:", "")
    text = string.gsub(text, "|A:[^|]+|a", "")
    text = string.gsub(text, "UE_COLOR:", "")
    if original then
        local numbers = {}
        for value in string.gfind(original, "%d[%d,.]*") do table.insert(numbers, value) end
        text = string.gsub(text, "%$(%d+)", function(index) return numbers[tonumber(index)] or ("$" .. index) end)
    end
    return text
end
function W.FindTranslation(database, text, numbers)
    if type(text) ~= "string" or text == "" then return nil end
    local candidates = {text, W.PlayerTokens(text), W.Normalize(text, false), (W.Trim(W.Normalize(text, false)))}
    -- WoWTR's gossip hashes also use versions with player tokens removed.
    local stripped = W.Normalize(text, false)
    stripped = string.gsub(stripped, "%$[NRCB]", "")
    table.insert(candidates, stripped)
    table.insert(candidates, (string.gsub(stripped, "%s+", " ")))
    if numbers then table.insert(candidates, W.Normalize(text, true)) end
    for _, candidate in ipairs(candidates) do
        local translation = W.Lookup(database, W.Hash(candidate))
        if translation then return W.Format(translation, text) end
    end
    return nil
end
function W.Missing(module, key, original)
    if not W.db or not W.db.saveMissing or not key or not original or original == "" then return end
    local log = WoWTRVanillaLog.missing
    local signature = module .. ":" .. tostring(key)
    if not log[signature] then
        local count = 0
        for _ in pairs(log) do count = count + 1 end
        if count >= 300 then return end
        log[signature] = string.sub(original, 1, 4000)
    end
end
function W.Replace(widget, translation, module)
    if not widget or type(widget.GetText) ~= "function" or not translation then return false end
    local current = widget:GetText()
    local previous = W.originals[widget]
    if previous and current == previous.translated then return true end
    local font, size, flags
    if widget.GetFont then font, size, flags = widget:GetFont() end
    W.originals[widget] = {text = current, translated = translation, font = font, size = size, flags = flags, module = module}
    if widget.SetFont then widget:SetFont(W.font, size or W.db.fontSize, flags) end
    widget:SetText(translation)
    return true
end
function W.Restore(module)
    for widget, value in pairs(W.originals) do
        if not module or value.module == module then
            if widget:GetText() == value.translated then
                widget:SetText(value.text)
                if value.font and widget.SetFont then widget:SetFont(value.font, value.size, value.flags) end
            end
            W.originals[widget] = nil
        end
    end
end
function W.TranslateWidget(widget, database, numbers, module)
    if not widget or not widget.GetText then return end
    local previous = W.originals[widget]
    if previous and widget:GetText() == previous.translated then return end
    W.Replace(widget, W.FindTranslation(database, widget:GetText(), numbers), module or database)
end
function W.NewFrame(kind, name, parent, template)
    return CreateFrame(kind, name, parent or UIParent, template)
end
function W.Backdrop(frame)
    frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left=4, right=4, top=4, bottom=4}})
    frame:SetBackdropColor(0.04, 0.04, 0.06, 0.95)
end
function W.Text(parent, size, text)
    local label = parent:CreateFontString(nil, "OVERLAY")
    label:SetFont(W.font, size or 14)
    label:SetText(text or "")
    return label
end
function W.Button(parent, text, width, callback)
    local button = W.NewFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetWidth(width or 85); button:SetHeight(22); button:SetText(text)
    local fontString = button:GetFontString()
    if fontString then fontString:SetFont(W.font, 12) end
    button:SetScript("OnClick", callback)
    return button
end
