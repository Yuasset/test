-- Geliştirme sırasında görünür tooltip'ları inceleme araçları.
-- Kullanım: Bir arayüz öğesinin üzerine gelin ve /run TTest() yazın.
function TTest()
   print("|cff00ff00[WoWTR]|r 3 saniye geri sayım başladı. Mouse'u hedefin üzerine götür ve bekle...")

   C_Timer.After(3, function()
      print("--------------------------------------------------")

      local focus
      if GetMouseFoci then
         local foci = GetMouseFoci()
         focus = foci and foci[1]
      end

      if focus then
         local focusName = focus:GetName() or "İsimsiz Frame (" .. tostring(focus) .. ")"
         print("Mouse altındaki nesne (OWNER):", focusName)
         if focus.tooltip then print("  -> Nesnenin .tooltip özelliği var.") end
         if focus.title then print("  -> Nesnenin .title özelliği var:", focus.title) end
      else
         print("Mouse altında bir UI nesnesi yok (WorldFrame üzerinde).")
      end

      local found = false
      local commonTooltips = {
         "GameTooltip",
         "ShoppingTooltip1",
         "ItemRefTooltip",
         "ItemRefShoppingTooltip1",
         "SharedTooltip",
         "WorldMapTooltip",
         "SmallTextTooltip",
         "ElvUI_SpellBookTooltip",
         "ElvUI_ToolTip",
         "TinyTooltip",
         "VignetteTooltip",
         "EmbeddedItemTooltip",
      }

      for _, name in ipairs(commonTooltips) do
         local tooltip = _G[name]
         if tooltip and tooltip:IsVisible() then
            found = true
            print("|cff00ff00--> Açık tooltip bulundu:|r", name)

            local numLines = tooltip:NumLines()
            print("    -> Satır sayısı:", numLines)

            local tooltipData = tooltip.processingInfo and tooltip.processingInfo.tooltipData
            if tooltipData then
               print("    -> Tooltip verisi bulundu:")
               if tooltipData.id then print("       -> ID:", tooltipData.id) end
               if tooltipData.type then print("       -> Tür:", tooltipData.type) end
            else
               print("    -> processingInfo/tooltipData yok (nil)")
            end

            local owner = tooltip.GetOwner and tooltip:GetOwner()
            if owner then
               print("    -> Sahibi:", owner:GetName() or tostring(owner))
               if owner.widgetID then print("       -> Owner.widgetID:", owner.widgetID) end
               if owner.widgetSetID then print("       -> Owner.widgetSetID:", owner.widgetSetID) end
               if owner.GetID then print("       -> Owner:GetID():", owner:GetID()) end

               if type(owner) == "table" then
                  for key, value in pairs(owner) do
                     if type(key) == "string" and string.find(string.lower(key), "id")
                        and (type(value) == "number" or type(value) == "string") then
                        print("       -> Bulunan anahtar [" .. key .. "]:", value)
                     end
                  end
               end
            end

            for i = 1, numLines do
               local line = _G[name .. "TextLeft" .. i]
               if not line and tooltip["TextLeft" .. i] then
                  line = tooltip["TextLeft" .. i]
               end

               if line then
                  local text = line:GetText()
                  if text then
                     print("       [" .. i .. "]: " .. string.gsub(text, "|", "||"))
                     if ST_RemoveRedundantCharacters and StringHash then
                        local cleanText = ST_RemoveRedundantCharacters(text)
                        print("           -> Hash:", StringHash(cleanText))
                     end
                  else
                     print("       [" .. i .. "]: <nil text>")
                  end
               else
                  print("       [" .. i .. "]: <nil region>")
               end
            end
         end
      end

      if not found then
         print("|cffff0000--> Hiçbir standart tooltip görünür değil.|r Çok özel bir frame olabilir.")
      end
      print("--------------------------------------------------")
   end)
end

-- Kullanım: İkonun üzerine gelin ve /run TTest2() yazın.
function TTest2()
   print("3 saniye içinde ikona gel...")
   C_Timer.After(3, function()
      local tooltip = GameTooltip
      if not tooltip:IsVisible() then
         print("Tooltip yok")
         return
      end

      print("--- Tooltip okundu ---")
      for i = 1, tooltip:NumLines() do
         local line = _G[tooltip:GetName() .. "TextLeft" .. i]
         if line then print(i, line:GetText()) end
      end
   end)
end