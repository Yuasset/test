-- Integration checks against the native Lua 5.0 VM and the 1.12 API shape.
local assertions = 0
local function check(value, message)
    assertions = assertions + 1
    if not value then error(message or "check failed") end
end
local Frame = {}
Frame.__index = Frame
function Frame:SetWidth(value) self.width = value end
function Frame:SetHeight(value) self.height = value end
function Frame:GetHeight() return self.height or 80 end
function Frame:SetPoint(...) self.point = arg end
function Frame:ClearAllPoints() self.point = nil end
function Frame:SetFrameStrata(value) self.strata = value end
function Frame:SetBackdrop(value) self.backdrop = value end
function Frame:SetBackdropColor(...) self.color = arg end
function Frame:SetMovable(value) self.movable = value end
function Frame:EnableMouse(value) self.mouse = value end
function Frame:RegisterForDrag(...) self.drag = arg end
function Frame:RegisterForClicks(...) self.clicks = arg end
function Frame:StartMoving() end
function Frame:StopMovingOrSizing() end
function Frame:Show()
    local changed = not self.shown
    self.shown = true
    if changed and self.scripts.OnShow then
        local savedThis = this; this = self; self.scripts.OnShow(); this = savedThis
    end
end
function Frame:Hide() self.shown = false end
function Frame:IsShown() return self.shown and (not self.parent or self.parent:IsShown()) end
function Frame:SetFont(font, size, flags) self.font = font; self.fontSize = size; self.flags = flags; return true end
function Frame:GetFont() return self.font or "Fonts\\FRIZQT__.ttf", self.fontSize or 12, self.flags end
function Frame:SetText(text)
    self.text = text
    if self.fontString then self.fontString:SetText(text) end
end
function Frame:GetText() return self.text end
function Frame:SetJustifyH(value) end
function Frame:SetJustifyV(value) end
function Frame:SetScrollChild(value) self.scrollChild = value end
function Frame:SetVerticalScroll(value) self.verticalScroll = value end
function Frame:UpdateScrollChildRect() end
function Frame:GetFontString() return self.fontString end
function Frame:SetScript(name, fn) self.scripts[name] = fn end
function Frame:GetScript(name) return self.scripts[name] end
function Frame:RegisterEvent(name) self.events[name] = true end
function Frame:GetName() return self.name end
function Frame:GetObjectType() return self.kind end
function Frame:GetParent() return self.parent end
function Frame:SetChecked(value) self.checked = value end
function Frame:GetChecked() return self.checked end
function Frame:SetNormalTexture(value) self.texture = value end
function Frame:SetHighlightTexture(value) end
function Frame:SetMultiLine(value) end
function Frame:SetAutoFocus(value) end
function Frame:SetFocus() end
function Frame:HighlightText() end
function Frame:SetOwner(owner, anchor) self.owner = owner end
function Frame:AddLine(text)
    table.insert(self.lines, text)
    if self.kind == "GameTooltip" then
        local name = self.name .. "TextLeft" .. table.getn(self.lines)
        local region = _G[name] or self:CreateFontString(name)
        region:SetText(text)
    end
end
function Frame:AddDoubleLine(left, right)
    self:AddLine(left)
    local name = self.name .. "TextRight" .. table.getn(self.lines)
    local region = _G[name] or self:CreateFontString(name)
    region:SetText(right)
end
function Frame:NumLines() return table.getn(self.lines) end
function Frame:GetCenter() return 0, 0 end
function Frame:GetEffectiveScale() return 1 end
function Frame:GetChildren() return unpack(self.children) end
function Frame:GetRegions() return unpack(self.regions) end
function Frame:CreateFontString(name, layer)
    local region = setmetatable({name=name, kind="FontString", parent=self, shown=true, scripts={}, events={}, children={}, regions={}, lines={}}, Frame)
    table.insert(self.regions, region)
    if name then _G[name] = region end
    return region
end

function CreateFrame(kind, name, parent, template)
    local frame = setmetatable({kind=kind, name=name, parent=parent, shown=true, scripts={}, events={}, children={}, regions={}, lines={}}, Frame)
    if parent then table.insert(parent.children, frame) end
    if name then _G[name] = frame end
    if kind == "Button" then frame.fontString = frame:CreateFontString(nil) end
    check(template ~= "BackdropTemplate", "Modern template used")
    return frame
end
UIParent = CreateFrame("Frame", "UIParent")
QuestFrame = CreateFrame("Frame", "QuestFrame", UIParent)
QuestLogFrame = CreateFrame("Frame", "QuestLogFrame", UIParent); QuestLogFrame:Hide()
ItemTextFrame = CreateFrame("Frame", "ItemTextFrame", UIParent)
ItemTextPageText = ItemTextFrame:CreateFontString("ItemTextPageText")
ItemTextTitleText = ItemTextFrame:CreateFontString("ItemTextTitleText")
GossipFrame = CreateFrame("Frame", "GossipFrame", UIParent)
GossipGreetingText = GossipFrame:CreateFontString("GossipGreetingText")
GameTooltip = CreateFrame("GameTooltip", "GameTooltip", UIParent)
GameTooltipTextLeft1 = GameTooltip:CreateFontString("GameTooltipTextLeft1")
GameTooltipTextRight1 = GameTooltip:CreateFontString("GameTooltipTextRight1")
ItemRefTooltip = CreateFrame("GameTooltip", "ItemRefTooltip", UIParent)
local tooltipSource = "Warrior gains 1,234 power."
local function nativeTooltipText(tooltip, text)
    tooltip.lines = {text}
    local name = tooltip:GetName() .. "TextLeft1"
    local region = _G[name] or tooltip:CreateFontString(name)
    region:SetText(text)
    local right = _G[tooltip:GetName() .. "TextRight1"]
    if right then right:SetText("") end
end
function GameTooltip:SetText(text) nativeTooltipText(self, text); return nil, "text", nil end
ItemRefTooltip.SetText = GameTooltip.SetText
function GameTooltip:SetBagItem(bag, slot)
    self.lastBag = bag; self.lastSlot = slot
    nativeTooltipText(self, tooltipSource)
    self:Show()
    return nil, 37, nil
end
function GameTooltip:SetInventoryItem(unit, slot)
    self.lastUnit = unit; self.lastSlot = slot
    nativeTooltipText(self, tooltipSource)
    return true, nil, 41
end
function ItemRefTooltip:SetHyperlink(link)
    self.lastLink = link
    nativeTooltipText(self, tooltipSource)
    return nil, "hyperlink", nil
end
-- An existing addon extends the tooltip before WoWTR installs its hooks.
local addonCalls = 0
local nativeBag = GameTooltip.SetBagItem
GameTooltip.SetBagItem = function(...)
    addonCalls = addonCalls + 1
    local result = {nativeBag(unpack(arg))}; result.n = 3
    arg[1]:AddLine("Existing addon line")
    return unpack(result)
end
local oldUpdateCalls = 0
GameTooltip:SetScript("OnUpdate", function()
    oldUpdateCalls = oldUpdateCalls + 1
    nativeTooltipText(this, tooltipSource)
    return nil, "old update", 9
end)
local oldShowCalls = 0
GameTooltip:SetScript("OnShow", function() oldShowCalls = oldShowCalls + 1 end)
ContainerFrame1 = CreateFrame("Frame", "ContainerFrame1", UIParent)
ContainerFrame1Name = ContainerFrame1:CreateFontString("ContainerFrame1Name")
ContainerFrame1Name:SetText("Backpack")
GameMenuButtonContinue = CreateFrame("Button", "GameMenuButtonContinue", UIParent)
GameMenuButtonContinue:SetText("Return to Game")
Minimap = CreateFrame("Frame", "Minimap", UIParent)
WorldFrame = CreateFrame("Frame", "WorldFrame", UIParent)
MerchantFrame = CreateFrame("Frame", "MerchantFrame", UIParent)
TutorialFrameText = UIParent:CreateFontString("TutorialFrameText")
CinematicFrame = CreateFrame("Frame", "CinematicFrame", UIParent)
UISpecialFrames = {}; SlashCmdList = {}
local chat = {}
DEFAULT_CHAT_FRAME = {AddMessage = function(self, text) table.insert(chat, text) end}
function UnitName(unit) return "Tester" end
function UnitClass(unit) return "Warrior" end
function UnitRace(unit) return "Human" end
function UnitSex(unit) return 2 end
function GetTime() return 100 end
function GetBuildInfo() return "1.18.1", "7272" end
function IsAddOnLoaded(name) return false end
function GetCursorPosition() return 100, 50 end
local title = "Kobold Camp Cleanup"
local objective = "Kill 10 Kobold Vermin, then return to Marshal McBride."
function GetTitleText() return title end
function GetQuestText() return "Original description" end
function GetObjectiveText() return objective end
function GetProgressText() return "Original progress" end
function GetRewardText() return "Original completion" end
function GetQuestLogSelection() return 1 end
function GetQuestLogTitle() return title, 3, nil, false, false, false end
function GetQuestLogQuestText() return "Log description", objective end
function QuestLog_Update() return nil, "preserved", 4 end
function GossipFrameUpdate() end
local bookTitle, bookSource, bookPage = "Unknown Book", "Original book", 1
function ItemTextGetItem() return bookTitle end
function ItemTextGetText() return bookSource end
function ItemTextGetPage() return bookPage end
function GetItemInfo(id) return "item", "item:123:0", id == 101 and 0 or 2 end
local combatLogging = false
function IsInInstance() return false end
function LoggingCombat(value) if value ~= nil then combatLogging = value end; return combatLogging end

local toc = assert(io.open("WoWTR.toc", "rb"))
for line in toc:lines() do
    if string.find(line, "%.lua%s*$") then dofile(string.gsub(line, "\\", "/")) end
end
toc:close()
local W = WoWTRV
local function dispatch(name, first, second)
    this = W.events; event = name; arg1 = first; arg2 = second
    W.events:GetScript("OnEvent")()
end
local function tick(delta)
    this = W.events; arg1 = delta; W.events:GetScript("OnUpdate")()
end
dispatch("ADDON_LOADED", "OtherAddon")
check(not W.initialized, "Initializes for unrelated addon")
dispatch("ADDON_LOADED", "WoWTR")
check(W.initialized and W.db.enabled, "Initialization failed")
check(table.getn(WoWTRVanillaLog.errors) == 0, "Initialization errors")
check(W.DataStats.quests > 4000, "Missing original quest corpus")
check(W.DataStats.gossip > 50000 and W.DataStats.tooltips > 100000, "Incomplete hash corpus")
local a, b, c = QuestLog_Update()
check(a == nil and b == "preserved" and c == 4, "Hook changed original return values")
local p, q, r = W.Protected("return-values", function() return nil, "second", 5 end)
check(p == nil and q == "second" and r == 5, "Protected call lost nil return values")
local id, method = W.ResolveQuest(title, objective)
check(id == 7, "Vanilla fallback resolved wrong quest: " .. tostring(id))
local explicit = W.ResolveQuest("No title", "", 99999)
check(explicit == 99999, "API quest ID lost")
W.Titles["Duplicate"] = {{11, "First objective"}, {12, "Second objective"}}
check(W.ResolveQuest("Duplicate", "Second objective extended") == 12, "Objective disambiguation failed")
local ambiguous, reason = W.ResolveQuest("Duplicate", "")
check(ambiguous == nil and reason == "ambiguous", "Ambiguous quest guessed")
W.Titles["Shared"] = {{12, "Same"}, {13, "Same"}}
check(W.ResolveQuest("Shared", "Same objective") == nil, "Repeated prefix guessed")
dispatch("QUEST_DETAIL")
tick(0.2)
check(W.reader and W.reader:IsShown(), "Quest reader missing")
check(W.questContext.resolvedID == 7, "Quest ID missing in reader")
check(string.find(W.reader.body:GetText(), "kobold", 1, true), "Original WoWTR quest translation missing")
dispatch("QUEST_PROGRESS"); tick(0.2)
check(string.find(W.reader.body:GetText(), W.Format(W.Quests["7"].Progress), 1, true), "Progress translation missing")
dispatch("QUEST_COMPLETE"); tick(0.2)
check(string.find(W.reader.body:GetText(), W.Format(W.Quests["7"].Completion), 1, true), "Reward translation missing")
W.readerEnglish = true; W.RenderQuest(W.questContext)
check(string.find(W.reader.body:GetText(), "Original completion", 1, true), "English reader toggle failed")
W.readerEnglish = false
QuestFrame:Hide(); QuestLogFrame:Show(); W.QuestLog()
check(W.questContext.stage == "log" and W.questContext.resolvedID == 7, "Quest log integration failed")
local originalTitle, originalObjective = title, objective
local originalObjectiveAPI = GetObjectiveText
title = "Duplicate"; objective = "Second objective extended"
GetObjectiveText = function() return "" end
dispatch("QUEST_PROGRESS"); tick(0.2)
check(W.questContext.resolvedID == 12, "Quest log objective fallback failed on turn-in")
title = originalTitle; objective = originalObjective; GetObjectiveText = originalObjectiveAPI
W.ShowOptions(); check(W.options:IsShown(), "Settings failed to open")
W.ShowOptions(); check(not W.options:IsShown(), "Settings failed to close")
W.ShowLog(); check(W.logFrame:IsShown(), "Diagnostics window failed")
check(string.find(W.logFrame.edit:GetText(), "7272", 1, true), "Client diagnostic missing")
local formatted = W.Format("$N $C $R$B$GHe:She; $1 %$2", "Deals 12 damage at 30%")
check(string.find(formatted, "Tester", 1, true) and string.find(formatted, "12 %30", 1, true), "Placeholder substitution failed")
-- Packed translation decoding preserves literal backslashes and tabs/newlines.
local hash = W.Hash("English gossip")
W.PackedDB.gossip[math.mod(hash, 512)+1] = "\n" .. string.format("%.0f", hash) .. "\tTürkçe\\nSatır\\tSekme\\\\n\n"
W.cache.gossip = {}; W.cacheSize.gossip = 0
GossipGreetingText:SetText("English gossip")
W.Gossip()
check(GossipGreetingText:GetText() == "Türkçe\nSatır\tSekme\\n", "Packed decoding failed")
W.db.gossip = false; W.Changed("gossip")
check(GossipGreetingText:GetText() == "English gossip", "Original text not restored on disable")
W.db.gossip = true
-- Tooltip numbers and class words follow the original WoWTR hash contract.
local tooltipEnglish = "Warrior gains 1,234 power."
local tooltipHash = W.Hash("Warrior gains  power.")
W.PackedDB.tooltips[math.mod(tooltipHash,512)+1] = "\n" .. string.format("%.0f",tooltipHash) .. "\tSavaşçı $1 güç kazanır.\n"
W.cache.tooltips = {}; W.cacheSize.tooltips = 0
GameTooltipTextLeft1:SetText(tooltipEnglish); GameTooltip.lines = {tooltipEnglish}
W.Tooltip(GameTooltip)
check(GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Tooltip hash/numeric translation failed")
W.db.tooltips = false; W.Changed("tooltips")
check(GameTooltipTextLeft1:GetText() == tooltipEnglish, "Tooltip disable did not restore English")
W.db.tooltips = true
-- Every native bag refresh must already be Turkish when it returns, without a timer.
GameTooltip:Hide()
local bagResult = W.Capture(GameTooltip:SetBagItem(0, 2))
check(GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "First bag hover waited for a timer")
check(bagResult.n == 3 and bagResult[1] == nil and bagResult[2] == 37 and bagResult[3] == nil, "Bag hook lost nil return values")
check(addonCalls == 1 and GameTooltipTextLeft2:GetText() == "Existing addon line", "Existing tooltip addon was overwritten")
check(oldShowCalls == 1 and GameTooltip.lastBag == 0 and GameTooltip.lastSlot == 2, "OnShow or bag arguments lost")
for refresh = 1, 60 do
    GameTooltip:SetBagItem(0, 2)
    check(GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "English frame after repeated bag refresh")
    tick(1 / 60)
    check(GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Timer changed stable tooltip")
end
check(addonCalls == 61, "Hook chain did not execute for each refresh")
this = GameTooltip; arg1 = 1 / 60
local u, v, z = GameTooltip:GetScript("OnUpdate")()
check(oldUpdateCalls == 1 and u == nil and v == "old update" and z == 9, "Original tooltip update lost")
check(GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Native script refresh remained English")
local inventoryResult = W.Capture(GameTooltip:SetInventoryItem("player", 16))
check(inventoryResult.n == 3 and inventoryResult[1] and inventoryResult[2] == nil and inventoryResult[3] == 41, "Inventory return values changed")
check(GameTooltip.lastUnit == "player" and GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Equipment tooltip remained English")
ItemRefTooltip:Hide()
local hyperlinkResult = W.Capture(ItemRefTooltip:SetHyperlink("item:123:0"))
check(hyperlinkResult.n == 3 and hyperlinkResult[2] == "hyperlink" and ItemRefTooltip.lastLink == "item:123:0", "Hyperlink hook changed native result")
check(ItemRefTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Hidden hyperlink tooltip was not translated before Show")
GameTooltip:AddDoubleLine(tooltipEnglish, tooltipEnglish)
check(GameTooltipTextLeft2:GetText() == "Savaşçı 1,234 güç kazanır." and GameTooltipTextRight2:GetText() == "Savaşçı 1,234 güç kazanır.", "New left/right lines remained English")
-- Skipping unchanged lines avoids repeating hash work in every tooltip OnUpdate.
local oldFind, lookupCalls = W.FindTranslation, 0
W.FindTranslation = function(...)
    lookupCalls = lookupCalls + 1
    return oldFind(unpack(arg))
end
W.Tooltip(GameTooltip); W.Tooltip(GameTooltip)
check(lookupCalls == 0, "Unchanged tooltip lines were needlessly rehashed")
W.FindTranslation = oldFind
tooltipSource = "Unknown custom server item"
GameTooltip:SetBagItem(0, 3)
check(GameTooltipTextLeft1:GetText() == tooltipSource, "Reused tooltip retained previous translation")
check(GameTooltipTextLeft1:GetFont() == "Fonts\\FRIZQT__.ttf", "Untranslated reused line retained addon font")
tooltipSource = tooltipEnglish
GameTooltip:SetBagItem(0, 2); GameTooltip:SetBagItem(0, 2)
W.db.tooltips = false; W.Changed("tooltips")
check(GameTooltipTextLeft1:GetText() == tooltipEnglish and GameTooltipTextLeft1:GetFont() == "Fonts\\FRIZQT__.ttf", "Repeated refresh lost original text/font for disable")
GameTooltip:SetBagItem(0, 2)
check(GameTooltipTextLeft1:GetText() == tooltipEnglish, "Disabled tooltip hook translated text")
W.db.tooltips = true; W.Changed("tooltips")
check(GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Tooltip setting did not refresh immediately")
local failingTooltip = CreateFrame("GameTooltip", "FailingTooltip", UIParent)
local failNext = true
function failingTooltip:SetBagItem()
    if failNext then failNext = false; error("native hook failure") end
    nativeTooltipText(self, tooltipEnglish)
end
W.HookTooltip(failingTooltip)
local succeeded = pcall(function() failingTooltip:SetBagItem() end)
check(not succeeded, "Original method error was swallowed")
failingTooltip:SetBagItem()
check(FailingTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Native method failure left hook depth stuck")
check(ContainerFrame1Name:GetText() == "Sırt Çantası", "Backpack label missing")
check(GameMenuButtonContinue:GetFontString():GetText() == "Oyuna Dön", "Basic menu label missing")
ContainerFrame1Name:SetText("Backpack")
check(ContainerFrame1Name:GetText() == "Sırt Çantası", "Bag label refresh waited for a timer")
QuestFrameAcceptButton = CreateFrame("Button", "QuestFrameAcceptButton", QuestFrame, "UIPanelButtonTemplate")
QuestFrameAcceptButton:SetText("Accept"); W.InterfaceText()
check(QuestFrameAcceptButton:GetFontString():GetText() == "Kabul Et", "Vanilla quest button translation failed")
QuestFrameAcceptButton:SetText("Decline")
check(QuestFrameAcceptButton:GetFontString():GetText() == "Reddet", "Button update remained English")
QuestFrameAcceptButton:SetText("Accept")
W.db.ui = false; W.Changed("ui")
check(QuestFrameAcceptButton:GetFontString():GetText() == "Accept", "UI disable did not restore English")
check(ContainerFrame1Name:GetText() == "Backpack" and ContainerFrame1Name:GetFont() == "Fonts\\FRIZQT__.ttf", "UI disable lost original bag label/font")
W.db.ui = true
W.Changed("ui")
check(ContainerFrame1Name:GetText() == "Sırt Çantası", "UI setting did not refresh immediately")
ContainerFrame1Name:SetText("Unknown custom bag")
check(ContainerFrame1Name:GetText() == "Unknown custom bag", "Unknown custom bag was overwritten")
check(ContainerFrame1Name:GetFont() == "Fonts\\FRIZQT__.ttf", "Unknown custom bag retained translation font")
ContainerFrame1Name:SetText("Backpack")
W.db.enabled = false; W.Changed("enabled")
check(ContainerFrame1Name:GetText() == "Backpack" and GameTooltipTextLeft1:GetText() == tooltipEnglish, "Disabling addon did not restore native texts")
W.db.enabled = true; W.Changed("enabled")
check(ContainerFrame1Name:GetText() == "Sırt Çantası" and GameTooltipTextLeft1:GetText() == "Savaşçı 1,234 güç kazanır.", "Enabling addon did not restore translation")
W.db.enabled = false; W.Changed("enabled")
check(ContainerFrame1Name:GetFont() == "Fonts\\FRIZQT__.ttf", "Toggle cycle lost original UI font")
W.db.enabled = true; W.Changed("enabled")
local widget = UIParent:CreateFontString(nil)
widget:SetText("A"); widget:SetFont("OriginalFont", 13, "OUTLINE")
W.Replace(widget, "TR A", "tooltips"); widget:SetText("New unrelated text"); W.Restore("tooltips")
check(widget:GetText() == "New unrelated text", "Restore overwrote a reused widget")
-- Book lookup works when composite lookup is absent and hash lookup succeeds.
W.Books[tostring(W.Hash(bookSource))] = {["1"]="Türkçe kitap", Title="Kitap"}
W.Book(); check(ItemTextPageText:GetText() == "Türkçe kitap", "Book hash fallback failed")
-- Optional automation defaults must remain off and never sell valuable/locked items.
check(not W.db.sellGrey and not W.db.combatLog, "Automation unexpectedly enabled")
local sold = {}
function GetContainerNumSlots(bag) return bag == 0 and 3 or 0 end
function GetContainerItemLink(bag, slot) return "item:" .. tostring(100 + slot) .. ":0" end
function GetContainerItemInfo(bag, slot) return nil, 1, slot == 3 end
function UseContainerItem(bag, slot) table.insert(sold, slot) end
W.db.sellGrey = true; W.SellGrey()
check(table.getn(sold) == 1 and sold[1] == 1, "Vendor sold valuable or locked item")
W.db.enabled = false; W.SellGrey(); check(table.getn(sold) == 1, "Disabled addon sold items")
W.db.enabled = true
-- Error reports are bounded and repeated errors are not spammed.
local function expectedError() error("intentional test") end
W.Protected("expected-test", expectedError)
local errorCount = table.getn(WoWTRVanillaLog.errors)
W.Protected("expected-test", expectedError)
check(table.getn(WoWTRVanillaLog.errors) == errorCount, "Duplicate errors spammed")
check(errorCount == 1, "Unexpected integration errors: " .. W.LogText())
print("PASS: " .. assertions .. " Lua 5.0 integration assertions")
local report = assert(io.open("tests/result.txt", "w"))
collectgarbage()
report:write("PASS: ", assertions, " integration assertions on ", _VERSION, "\n", "Lua heap KB after collection: ", gcinfo(), "\n")
report:close()
