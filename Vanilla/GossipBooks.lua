local W = WoWTRV

function W.Gossip()
    if not W.Active("gossip") then return end
    for _, widget in ipairs({GossipGreetingText or false, GreetingText or false}) do
        if widget then W.TranslateWidget(widget, "gossip", false, "gossip") end
    end
    for i = 1, 32 do
        local button = _G["GossipTitleButton" .. i]
        if button and button:IsShown() then
            local label = button.GetFontString and button:GetFontString()
            if label then W.TranslateWidget(label, "gossip", false, "gossip") end
        end
    end
end

function W.Book()
    if not W.Active("books") or not ItemTextFrame or not ItemTextFrame:IsShown() then return end
    local title = ItemTextGetItem and ItemTextGetItem() or ""
    local page = tostring(ItemTextGetPage and ItemTextGetPage() or 1)
    if page == "0" then page = "1" end
    local source = ItemTextGetText and ItemTextGetText() or ""
    local normalized = W.PlayerTokens(source)
    local withoutLines = string.gsub(normalized, "\n", "")
    local composite = title .. "#" .. page .. "#" .. string.sub(withoutLines, 1, 15)
    local candidates = {W.BookIDs[composite], tostring(W.Hash(normalized)), tostring(W.Hash(source))}
    if type(GetItemInfo) == "function" then
        local _, link = GetItemInfo(title)
        if link then
            local _, _, id = string.find(link, "item:(%d+)")
            if id then candidates[4] = id end
        end
    end
    local record
    -- ipairs stops at nil: explicitly traverse every possible candidate.
    for i = 1, 4 do
        local key = candidates[i]
        if key and W.Books[key] and W.Books[key][page] then record = W.Books[key]; break end
    end
    if record then
        W.Replace(ItemTextPageText, W.Format(record[page]), "books")
        if record.Title then W.Replace(ItemTextTitleText, W.Format(record.Title), "books") end
    else W.Missing("book", composite, source) end
end

function W.InitGossipBooks()
    W.Hook("GossipFrameUpdate", function() W.Later(0.02, W.Gossip, "gossip") end)
    W.Hook("QuestFrameGreetingPanel_OnShow", function() W.Later(0.02, W.Gossip, "gossip") end)
    W.Hook("ItemTextFrame_OnEvent", function() W.Later(0.02, W.Book, "book") end)
end
