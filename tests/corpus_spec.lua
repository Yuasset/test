-- Validate every generated hash value against the original WoWTR data.
local function loadData(path)
    local file = assert(io.open(path, "rb")); local text = file:read("*a"); file:close()
    if string.sub(text, 1, 3) == string.char(239,187,191) then text = string.sub(text,4) end
    local env = {}; setmetatable(env,{__index=_G})
    local fn = assert(loadstring(text,"@"..path)); setfenv(fn,env); fn(); return env
end
dofile("Vanilla/Bootstrap.lua")
local W = WoWTRV
local files = {
    {"gossip", "Translations/Gossip_TR.lua", "GS_Gossip", "DataGossip.lua"},
    {"tooltips", "Translations/Tooltips_TR.lua", "ST_TooltipsHS", "DataTooltips.lua"},
    {"bubbles", "Translations/Bubbles_TR.lua", "BB_Bubbles", "DataBubbles.lua"},
    {"tutorials", "Translations/TutorialsData7_TR.lua", "Tut_Data7", "DataTutorials.lua"},
}
local total = 0
for _, source in ipairs(files) do
    dofile("Vanilla/" .. source[4])
    local data = loadData(source[2])[source[3]]
    local count = 0
    for hash, translation in pairs(data) do
        assert(W.Lookup(source[1], hash) == translation, source[1] .. " translation changed: " .. tostring(hash))
        count = count + 1
    end
    print("CORPUS PASS: " .. source[1] .. " " .. count)
    total = total + count
    W.PackedDB[source[1]] = nil; W.cache[source[1]] = nil
    data = nil; collectgarbage()
end
local function equal(a,b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for key,value in pairs(a) do if not equal(value,b[key]) then return false end end
    for key in pairs(b) do if a[key] == nil then return false end end
    return true
end
dofile("Vanilla/DataQuests.lua")
assert(equal(W.Quests, loadData("Source/Era/QuestData1_TR.lua").QTR_QuestData), "Quest data changed")
dofile("Vanilla/DataBooks.lua"); dofile("Vanilla/DataBookIDs.lua")
local books = loadData("Translations/Books_TR.lua")
assert(equal(W.Books, books.BT_Books) and equal(W.BookIDs,books.BT_BooksID), "Book data changed")
print("CORPUS PASS: " .. total .. " hash records; full quest and book tables match originals")
