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
    if self.kind == "GameTooltip" then
        local first = _G[self.name .. "TextLeft1"]
        self.layoutText = first and first:GetText()
    end
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
function GameTooltip:SetUnit(unit)
    self:SetText("Attack")
    return true
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
    if string.find(line, "%.lua%s*$") then dofile((string.gsub((string.gsub(line, "%s+$", "")), "\\", "/"))) end
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
check(not W.db.reader, "Separate reader should be optional by default")
W.db.reader = true
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
-- Visible text is translated inside the real quest widgets, without changing game API values.
local nativeNames = {"QuestTitleText", "QuestDescription", "QuestObjectiveText", "QuestProgressTitleText", "QuestProgressText", "QuestRewardTitleText", "QuestRewardText", "QuestLogQuestTitle", "QuestLogQuestDescription", "QuestLogObjectivesText"}
for _, name in ipairs(nativeNames) do
    local parent = string.find(name, "^QuestLog") and QuestLogFrame or QuestFrame
    parent:CreateFontString(name)
end
QuestLogDetailScrollFrame = CreateFrame("ScrollFrame", "QuestLogDetailScrollFrame", QuestLogFrame)
local sourceTitle = "Your Place In The World"
local sourceDescription = "Original quest description"
local sourceObjectives = "Speak with Gornek."
local nativeContext = {title=sourceTitle, description=sourceDescription, objectives=sourceObjectives, stage="log", id=4641, parent=QuestLogFrame}
W.db.reader = false; W.readerEnglish = false; W.InterfaceText(); W.RenderQuest(nativeContext)
check(QuestLogQuestTitle:GetText() == W.Format(W.Quests["4641"].Title), "Native quest title not translated")
check(QuestLogQuestDescription:GetText() == W.Format(W.Quests["4641"].Description), "Native quest body remained English")
check(QuestLogObjectivesText:GetText() == W.Format(W.Quests["4641"].Objectives), "Native quest objectives remained English")
check(not W.reader:IsShown(), "Optional reader still covered the game")
check(GetQuestLogTitle() == title, "Quest API source title was modified")
W.readerEnglish = true; W.RenderQuest(nativeContext)
check(QuestLogQuestTitle:GetText() == sourceTitle and QuestLogQuestDescription:GetText() == sourceDescription, "Native quest English toggle failed")
W.readerEnglish = false; W.RenderQuest(nativeContext)
W.db.questTitles = false; W.Changed("questTitles"); W.RenderQuest(nativeContext)
check(QuestLogQuestTitle:GetText() == sourceTitle and QuestLogQuestDescription:GetText() ~= sourceDescription, "Quest title setting changed body translation")
W.db.questTitles = true
for _, pair in ipairs({{"details", "QuestDescription"}, {"progress", "QuestProgressText"}, {"reward", "QuestRewardText"}}) do
    nativeContext.stage=pair[1]; nativeContext.parent=QuestFrame
    W.RenderQuest(nativeContext)
    local field = pair[1] == "details" and "Description" or (pair[1] == "progress" and "Progress" or "Completion")
    check(_G[pair[2]]:GetText() == W.Format(W.Quests["4641"][field]), "Native NPC quest stage remained English")
end
nativeContext.stage="log"; nativeContext.parent=QuestLogFrame
W.RenderQuest(nativeContext)
local unknownContext = {title="Custom server quest", description="New untranslated quest body", objectives="Custom task", stage="log", parent=QuestLogFrame, id=987654}
W.RenderQuest(unknownContext)
check(QuestLogQuestDescription:GetText() == unknownContext.description, "Missing quest retained the previous Turkish body")
check(QuestLogQuestDescription:GetFont() == "Fonts\\FRIZQT__.ttf", "Missing quest retained translation font")
W.RenderQuest(nativeContext)
W.db.quests=false; W.Changed("quests")
check(QuestLogQuestDescription:GetText() == sourceDescription, "Quest disable did not restore native body")
W.db.quests=true
-- Anonymous labels and descendants are discovered, with immediate updates after installation.
SpellBookFrame = CreateFrame("Frame", "SpellBookFrame", UIParent)
SpellBookTitleText = SpellBookFrame:CreateFontString("SpellBookTitleText")
SpellBookTitleText:SetText("Spellbook")
local previousLabel = SpellBookFrame:CreateFontString(nil); previousLabel:SetText("Prev")
local spellButton = CreateFrame("Button", "SpellButton1", SpellBookFrame)
local spellLabel = spellButton:CreateFontString("SpellButton1SpellName"); spellLabel:SetText("Blood Fury")
local rankLabel = spellButton:CreateFontString("SpellButton1SubSpellName"); rankLabel:SetText("Racial")
SkillFrame = CreateFrame("Frame", "SkillFrame", UIParent)
local skillLabel = SkillFrame:CreateFontString("SkillRankFrame1SkillName"); skillLabel:SetText("Two-Handed Axes")
local sectionLabel = SkillFrame:CreateFontString(nil); sectionLabel:SetText("Armor Proficiencies")
PlayerFrame = CreateFrame("Frame", "PlayerFrame", UIParent)
PlayerName = PlayerFrame:CreateFontString("PlayerName"); PlayerName:SetText("Attack")
PlayerFrameHealthBarText = PlayerFrame:CreateFontString("PlayerFrameHealthBarText"); PlayerFrameHealthBarText:SetText("Health 80 / 80")
local chatFrame = CreateFrame("ScrollingMessageFrame", "ChatFrameTest", PlayerFrame)
local chatText = chatFrame:CreateFontString(nil); chatText:SetText("Attack")
local editBox = CreateFrame("EditBox", "UserInputTest", SpellBookFrame); editBox:SetText("Attack")
MinimapZoneText = Minimap:CreateFontString("MinimapZoneText"); MinimapZoneText:SetText("Valley of Trials")
local questButton = CreateFrame("Button", "QuestLogTitle1", QuestLogFrame); questButton:SetText("  Your Place In The World")
questButton:GetFontString().name = "QuestLogTitle1NormalText"
local savedTitle, savedObjective = title, objective
title=sourceTitle; objective="Speak with Gornek. You recall Kaltunk marking your map."
W.InterfaceText()
check(SpellBookTitleText:GetText()=="Büyü Kitabı" and previousLabel:GetText()=="Önceki", "Named or anonymous spellbook label remained English")
check(spellLabel:GetText()=="Kan Hiddeti" and rankLabel:GetText()=="Irksal", "Spell name/rank not localized")
check(skillLabel:GetText()=="İki Elli Baltalar" and sectionLabel:GetText()=="Zırh Yetkinlikleri", "Skill list not localized")
check(PlayerFrameHealthBarText:GetText()=="Sağlık 80 / 80", "Live health text not localized")
check(MinimapZoneText:GetText()=="Sınamalar Vadisi", "Minimap region not localized")
check(questButton:GetFontString():GetText()=="  "..W.Format(W.Quests["4641"].Title), "Quest list title not localized")
title=savedTitle; objective=savedObjective
check(PlayerName:GetText()=="Attack" and chatText:GetText()=="Attack" and editBox:GetText()=="Attack", "Player name, chat, or user input was altered")
spellLabel:SetText("Heroic Strike"); PlayerFrameHealthBarText:SetText("Health 73 / 80")
check(spellLabel:GetText()=="Kahramanca Vuruş" and PlayerFrameHealthBarText:GetText()=="Sağlık 73 / 80", "Dynamic UI refresh reverted to English")
W.db.ui=false; W.Changed("ui")
check(spellLabel:GetText()=="Heroic Strike" and previousLabel:GetText()=="Prev", "UI disable failed to restore scanned widgets")
W.db.ui=true; W.Changed("ui")
check(spellLabel:GetText()=="Kahramanca Vuruş", "UI re-enable failed")
GameTooltip:SetText("Tough Jerky")
check(GameTooltipTextLeft1:GetText()=="Sert Kurutulmuş Et", "Item name not translated")
check(GameTooltip.layoutText=="Sert Kurutulmuş Et", "Tooltip backdrop was not reflowed after translation")
GameTooltip:SetUnit("target")
check(GameTooltipTextLeft1:GetText()=="Attack", "Unit proper name was translated")
local hearthstone = "Use: Returns you to Durotar. Speak to an Innkeeper in a different place to change your home location."
local hearthTranslation = W.DisplayTranslation(hearthstone,true)
check(hearthTranslation and string.find(hearthTranslation,"Durotar",1,true) and not string.find(hearthTranslation,"Speak",1,true), "Hearthstone dynamic location not translated")
check(string.find(W.DisplayTranslation(hearthstone.." (30 Min Cooldown)",true),"30 dakika",1,true), "Hearthstone cooldown lost")
local fury = W.DisplayTranslation("Increases attack power by 2 and damage done by magical spells and effects by up to 1 for 15 sec. Reduces healing effects on you by 25% for 25 sec.",true)
check(fury and string.find(fury,"gücünü 2",1,true) and string.find(fury,"%25",1,true) and string.find(fury,"15 saniye",1,true), "OctoWoW Blood Fury mechanics/numbers were lost")
check(W.Format("$1 güç", "|cffffd2001,234|r power")=="1,234 güç", "Color code digits polluted number placeholders")
local function missingCount() local count=0; for _ in pairs(WoWTRVanillaLog.missing) do count=count+1 end; return count end
local missingBefore = missingCount()
W.RecordUntranslated("tooltips", "Unknown periodic text 100 damage")
W.RecordUntranslated("tooltips", "Unknown periodic text 101 damage")
check(missingCount()==missingBefore+1, "Changing numbers flooded missing-text capture")
check(W.DisplayTranslation("Agility:",true)=="Çeviklik:", "Colon UI label remained English")
check(W.DisplayTranslation("0.50 sec cast",true)=="0.50 saniyede yapılır", "Decimal cast time not preserved")
check(W.DisplayTranslation("(12.7 damage per second)",true)=="(saniyede 12.7 hasar)", "DPS float not translated")
check(W.DisplayTranslation("4.25% chance to dodge",true)=="%4.25 sıyrılma şansı", "Literal percent/template mismatch")
check(W.DisplayTranslation("Requires Blacksmithing (225)",true)=="Gereksinim: Demircilik (225)", "Profession requirement not localized")
check(W.DisplayTranslation("Attack has invited you to join a group.",true)=="Attack sizi bir gruba davet etti.", "Template changed a player proper name")
check(W.DisplayTranslation("This item cannot stack.",true)=="Bu eşya istiflenemez.", "Inventory system error remained English")
UIErrorsFrame=CreateFrame("MessageFrame","UIErrorsFrame",UIParent)
function UIErrorsFrame:AddMessage(text, red, green, blue, id)
    self.message=text; self.messageRed=red; self.messageID=id
    return nil,"message",nil
end
W.InterfaceText()
local errorResult=W.Capture(UIErrorsFrame:AddMessage("This item cannot stack.",1,0.2,0.3,17))
check(UIErrorsFrame.message=="Bu eşya istiflenemez." and UIErrorsFrame.messageRed==1 and UIErrorsFrame.messageID==17, "Error frame lost translated message/color/id")
check(errorResult.n==3 and errorResult[2]=="message", "Error frame hook changed nil return values")
W.db.ui=false; W.Changed("ui")
check(UIErrorsFrame:GetFont()=="Fonts\\FRIZQT__.ttf", "Error frame font not restored on disable")
UIErrorsFrame:AddMessage("This item cannot stack.")
check(UIErrorsFrame.message=="This item cannot stack.", "Disabled error message translation remained active")
W.db.ui=true; W.Changed("ui")
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
