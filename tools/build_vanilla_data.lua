-- Run with Lua 5.0 from the repository root. The original WoWTR corpus is unchanged.
local function loadDatabase(path)
    local file = assert(io.open(path, "rb"))
    local text = file:read("*a")
    file:close()
    if string.sub(text, 1, 3) == string.char(239, 187, 191) then text = string.sub(text, 4) end
    local fn = assert(loadstring(text, "@" .. path))
    local env = {}
    setmetatable(env, {__index = _G})
    setfenv(fn, env)
    fn()
    return env
end

local function keys(tab)
    local result = {}
    for key in pairs(tab) do table.insert(result, key) end
    table.sort(result, function(a, b) return tostring(a) < tostring(b) end)
    return result
end

local function serialize(file, value)
    if type(value) == "string" then file:write(string.format("%q", value))
    elseif type(value) == "number" then file:write(string.format("%.0f", value))
    elseif type(value) == "table" then
        file:write("{\n")
        for _, key in ipairs(keys(value)) do
            file:write("[")
            serialize(file, key)
            file:write("]=")
            serialize(file, value[key])
            file:write(",\n")
        end
        file:write("}")
    else error("Unsupported data type: " .. type(value)) end
end

local stats = {}
local function outputTable(filename, variable, data)
    local file = assert(io.open("Vanilla/" .. filename, "wb"))
    file:write("-- Generated from the original WoWTR translation database.\n", variable, " = ")
    serialize(file, data)
    file:write("\n")
    file:close()
end

local function encode(value)
    value = string.gsub(value, "\\", "\\\\")
    value = string.gsub(value, "\n", "\\n")
    value = string.gsub(value, "\r", "\\r")
    return string.gsub(value, "\t", "\\t")
end

local function packed(filename, name, data)
    local buckets = {}
    local count = 0
    for _, key in ipairs(keys(data)) do
        local value = data[key]
        if type(key) == "number" and type(value) == "string" then
            local bucket = math.mod(key, 512) + 1
            if not buckets[bucket] then buckets[bucket] = {} end
            table.insert(buckets[bucket], string.format("%.0f", key) .. "\t" .. encode(value))
            count = count + 1
        end
    end
    local file = assert(io.open("Vanilla/" .. filename, "wb"))
    file:write("-- WoWTR corpus stored in buckets to avoid allocating a table per translation.\n")
    file:write("WoWTRV.PackedDB.", name, " = {\n")
    for i = 1, 512 do
        if buckets[i] then
            file:write("[", i, "]=", string.format("%q", "\n" .. table.concat(buckets[i], "\n") .. "\n"), ",\n")
        end
    end
    file:write("}\n")
    file:close()
    stats[name] = count
    print(name .. ": " .. count .. " translations")
end

local questEnv = loadDatabase("Source/Era/QuestData1_TR.lua")
outputTable("DataQuests.lua", "WoWTRV.Quests", questEnv.QTR_QuestData)
stats.quests = table.getn(keys(questEnv.QTR_QuestData))
local books = loadDatabase("Translations/Books_TR.lua")
outputTable("DataBooks.lua", "WoWTRV.Books", books.BT_Books)
outputTable("DataBookIDs.lua", "WoWTRV.BookIDs", books.BT_BooksID)
stats.books = table.getn(keys(books.BT_Books))
packed("DataGossip.lua", "gossip", loadDatabase("Translations/Gossip_TR.lua").GS_Gossip)
packed("DataTooltips.lua", "tooltips", loadDatabase("Translations/Tooltips_TR.lua").ST_TooltipsHS)
packed("DataBubbles.lua", "bubbles", loadDatabase("Translations/Bubbles_TR.lua").BB_Bubbles)
packed("DataTutorials.lua", "tutorials", loadDatabase("Translations/TutorialsData7_TR.lua").Tut_Data7)

local function hash(text)
    local counter = 1
    local length = string.len(text)
    for i = 1, length, 3 do
        counter = math.mod(counter * 8161, 4294967279)
        counter = counter + string.byte(text, i) * 16776193
        counter = counter + (string.byte(text, i + 1) or (length - i + 256)) * 8372226
        counter = counter + (string.byte(text, i + 2) or (length - i + 256)) * 3932164
    end
    return math.mod(counter, 4294967291)
end

local movieEnv = loadDatabase("Source/Era/Subtitles_TR.lua")
local subtitles = movieEnv.MF_Hash
for _, record in pairs(movieEnv.MF_Data) do
    if record.ORYG and record.NAPIS then subtitles[hash(record.ORYG)] = record.NAPIS end
end
packed("DataSubtitles.lua", "subtitles", subtitles)

-- Only factual English quest names/IDs and objective prefixes are imported.
-- Source: https://github.com/devteabct78/QuestTranslator-Vanilla-Turkish/blob/main/QuestList.lua
local list = loadDatabase("tools/QuestList.source.lua").QuestTranslator_QuestList
local titles = {}
local seen = {}
for key, value in pairs(list) do
    local title = string.gsub(key, "_QTR_DUP_%d+$", "")
    local ids = type(value) == "table" and tostring(value[1]) or tostring(value)
    local prefix = type(value) == "table" and value[2] or ""
    if type(prefix) ~= "string" then prefix = "" end
    for idText in string.gfind(ids, "%d+") do
        local id = tonumber(idText)
        local signature = title .. ":" .. idText .. ":" .. prefix
        if id and not seen[signature] then
            seen[signature] = true
            if not titles[title] then titles[title] = {} end
            table.insert(titles[title], {id, prefix})
        end
    end
end
for _, candidates in pairs(titles) do
    table.sort(candidates, function(a, b)
        if a[1] == b[1] then return a[2] < b[2] end
        return a[1] < b[1]
    end)
end
local questNames = loadDatabase("tools/QuestNames.source.lua").WoWTRV_QuestNames
for id, title in pairs(questNames) do
    if questEnv.QTR_QuestData[tostring(id)] then
        local candidates = titles[title] or {}
        local present = false
        for _, candidate in ipairs(candidates) do if candidate[1] == id then present = true end end
        if not present then table.insert(candidates, {id, ""}); titles[title] = candidates end
    end
end
outputTable("DataTitles.lua", "WoWTRV.Titles", titles)
stats.titles = table.getn(keys(titles))
outputTable("DataStats.lua", "WoWTRV.DataStats", stats)
print("Quest records: " .. stats.quests .. "; English titles: " .. stats.titles)
