local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
local ConfigUIUtils = PeaversCommons and PeaversCommons.ConfigUIUtils
local Utils = PeaversCommons and PeaversCommons.Utils

local MacroUI = {}

function MacroUI:InitializeOptions()
    local panel = CreateFrame("Frame", addonName .. "MacroPanel", UIParent)
    panel.name = "Macro"
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Macro Instructions")
    
    -- Instructions
    local instructionsText = [[
|cffffd700How to use the Hero Path macro:|r

1. The addon automatically creates a macro called "PeaversHeroPath"
2. Open your macro window with |cff3abdf7/macro|r
3. Find the "PeaversHeroPath" macro in the General Macros tab
4. Drag it to your action bar
5. When you click a spell in the Hero Path window, the macro will update
6. Click the macro on your action bar to cast the selected spell

|cffffd700Note:|r The macro will show the icon and tooltip of the currently selected spell.
]]
    
    local instructions = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    instructions:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    instructions:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
    instructions:SetText(instructionsText)
    instructions:SetJustifyH("LEFT")
    instructions:SetJustifyV("TOP")
    
    -- Recreate Macro button
    local recreateButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    recreateButton:SetSize(160, 22)
    recreateButton:SetPoint("TOPLEFT", 16, -220)
    recreateButton:SetText("Recreate Macro")
    recreateButton:SetScript("OnClick", function()
        -- Create or update the macro
        local macroName = "PeaversHeroPath"
        local macroIndex = GetMacroIndexByName(macroName)
        
        if macroIndex == 0 then
            -- Create new macro with portal icon
            CreateMacro(macroName, "Interface\\Icons\\spell_arcane_portalundercity", "", false)
            Utils.Print("Macro created: " .. macroName)
        else
            -- Update existing macro to ensure it has proper icon
            EditMacro(macroIndex, macroName, "Interface\\Icons\\spell_arcane_portalundercity", "")
            Utils.Print("Macro recreated: " .. macroName)
        end
        
        Utils.Print("Open your macro window with /macro and drag 'PeaversHeroPath' to your action bar")
    end)
    
    -- Help text for button
    local buttonHelp = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    buttonHelp:SetPoint("TOPLEFT", recreateButton, "BOTTOMLEFT", 0, -4)
    buttonHelp:SetText("Click this button if you accidentally deleted the macro")
    
    -- Support section is handled automatically by PeaversCommons
    
    -- Add callbacks
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    
    return panel
end

function MacroUI:Initialize()
    self.panel = self:InitializeOptions()
end

addon.MacroUI = MacroUI
return MacroUI