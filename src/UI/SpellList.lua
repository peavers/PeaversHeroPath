local _, addon = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons and PeaversCommons.Utils

local SpellList = {}
local scrollFrame
local buttons = {}
local BUTTON_HEIGHT = 48
local BUTTON_SPACING = 2

function SpellList.Create(parent)
    if scrollFrame then return scrollFrame end

    -- Create scroll frame with modern Dragonflight scrollbar - full width
    scrollFrame = CreateFrame("ScrollFrame", "PeaversHeroPathScrollFrame", parent, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -50)  -- Below search bar, small margin
    scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)  -- Full width with minimal margins

    -- Move the scrollbar to the left by 20 pixels
    local scrollBar = scrollFrame.ScrollBar
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -10, -16)
        scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -10, 16)
    end

    -- Create content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth() - 20, 1)  -- Account for wider layout
    scrollFrame:SetScrollChild(content)
    scrollFrame.content = content

    return scrollFrame
end

function SpellList.CreateButton(index)
    local button = CreateFrame("Button", "PeaversHeroPathButton" .. index, scrollFrame.content)
    button:SetHeight(BUTTON_HEIGHT)
    button:SetPoint("LEFT", 4, 0)
    button:SetPoint("RIGHT", -4, 0)  -- Use 98% of available width
    
    -- Clean minimal styling like currency window
    button:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight")
    
    -- Set highlight texture properties - very subtle
    local highlightTexture = button:GetHighlightTexture()
    highlightTexture:SetVertexColor(1, 1, 1, 0.2)
    highlightTexture:SetAllPoints()
    
    -- Tooltip on hover
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.spellId then
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        end
    end)
    
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Click handler to update the macro
    button:SetScript("OnClick", function(self)
        if self.spellId and self.isKnown then
            local spellInfo = C_Spell.GetSpellInfo(self.spellId)
            local spellName = spellInfo and spellInfo.name
            
            if spellName then
                local macroName = "PeaversHeroPath"
                local macroBody = "#showtooltip\n/cast " .. spellName
                
                -- Get the spell texture for the icon
                local spellTexture = C_Spell.GetSpellTexture(self.spellId)
                local iconTexture = spellTexture or "Interface\\Icons\\spell_arcane_portalundercity"
                
                -- Create or update the actual macro
                local macroIndex = GetMacroIndexByName(macroName)
                if macroIndex == 0 then
                    -- Create new macro
                    macroIndex = CreateMacro(macroName, iconTexture, macroBody, nil)
                    if macroIndex > 0 then
                        print("Created PeaversHeroPath macro")
                    else
                        print("Failed to create macro - you may have too many macros")
                        return
                    end
                else
                    -- Update existing macro
                    EditMacro(macroIndex, macroName, iconTexture, macroBody)
                end
                
                if macroIndex > 0 then
                    -- Update portrait with the same icon logic
                    local gameIcon = C_Spell.GetSpellTexture(self.spellId)
                    local iconTexture = gameIcon or self.spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
                    addon.MainFrame.UpdatePortrait(iconTexture)
                end
            end
        else
            -- Do nothing for unknown spells - no error message needed
        end
    end)
    
    -- Icon - clean and simple like currency window
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("LEFT", 16, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)  -- Crop edges for cleaner look
    button.icon = icon
    
    -- Name
    local name = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("LEFT", icon, "RIGHT", 16, 6)
    name:SetPoint("RIGHT", -40, 6)
    name:SetJustifyH("LEFT")
    button.name = name
    
    -- Zone/Expansion info
    local info = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    info:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    info:SetPoint("RIGHT", -40, -4)
    info:SetJustifyH("LEFT")
    button.info = info
    
    -- Lock icon for unknown spells
    local lockIcon = button:CreateTexture(nil, "OVERLAY")
    lockIcon:SetSize(16, 16)
    lockIcon:SetPoint("RIGHT", -16, 0)
    lockIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-LOCK")
    lockIcon:SetVertexColor(0.7, 0.7, 0.7, 1)
    lockIcon:Hide()
    button.lockIcon = lockIcon
    
    return button
end

function SpellList.UpdateList(spells)
    if not scrollFrame then return end
    
    -- Hide all existing buttons
    for _, button in ipairs(buttons) do
        button:Hide()
    end
    
    -- No filtering needed - show all Hero Path spells
    local filteredSpells = spells
    
    -- Sort spells: known first, then by name
    table.sort(filteredSpells, function(a, b)
        local aKnown = addon.HeroPathData.IsSpellKnown(a.spellId)
        local bKnown = addon.HeroPathData.IsSpellKnown(b.spellId)
        
        if aKnown ~= bKnown then
            return aKnown
        end
        
        return a.name < b.name
    end)
    
    -- Create/update buttons
    local yOffset = -5
    for i, spell in ipairs(filteredSpells) do
        local button = buttons[i]
        if not button then
            button = SpellList.CreateButton(i)
            buttons[i] = button
        end
        
        -- Update button data
        button.spellId = spell.spellId
        button.spellDisplayName = spell.name  -- Store display name for status
        
        -- Get spell icon from game API first, fallback to data
        local gameIcon = C_Spell.GetSpellTexture(spell.spellId)
        button.spellIcon = gameIcon or spell.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        button.icon:SetTexture(button.spellIcon)
        button.name:SetText(spell.name)
        button.info:SetText(spell.zone .. " • " .. spell.expansion)
        
        -- Check if spell is known
        local isKnown = addon.HeroPathData.IsSpellKnown(spell.spellId)
        button.isKnown = isKnown
        
        if isKnown then
            button.name:SetTextColor(1, 1, 1)
            button.info:SetTextColor(1, 0.82, 0)  -- Blizzard gold
            button.lockIcon:Hide()
            button:EnableMouse(true)
        else
            button.name:SetTextColor(0.6, 0.6, 0.6)
            button.info:SetTextColor(0.5, 0.5, 0.5)
            button.lockIcon:Show()
            button:EnableMouse(true)  -- Still allow tooltip
        end
        
        -- Position button
        button:SetPoint("TOP", scrollFrame.content, "TOP", 0, yOffset)
        button:Show()
        
        yOffset = yOffset - (BUTTON_HEIGHT + BUTTON_SPACING)
    end
    
    -- Update content height
    local totalHeight = #filteredSpells * (BUTTON_HEIGHT + BUTTON_SPACING) + 10
    scrollFrame.content:SetHeight(totalHeight)
    
    -- Reset scroll position
    scrollFrame:SetVerticalScroll(0)
end

addon.SpellList = SpellList
return SpellList