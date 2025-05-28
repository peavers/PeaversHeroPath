local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
local ConfigUIUtils = PeaversCommons and PeaversCommons.ConfigUIUtils
local Utils = PeaversCommons and PeaversCommons.Utils

local ConfigUI = {}

function ConfigUI:InitializeOptions()
    local panel = CreateFrame("Frame", addonName .. "ConfigPanel", UIParent)
    panel.name = "Settings"
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Peavers Hero Path Settings")
    
    -- Description
    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("Configure Hero Path portal addon settings")
    desc:SetJustifyH("LEFT")
    desc:SetWidth(panel:GetWidth() - 32)
    
    local yOffset = -80
    
    -- Show Unknown Spells checkbox
    local showUnknownCheckbox = ConfigUIUtils.CreateCheckbox(
        panel,
        "Show Unknown Spells",
        "Display Hero Path spells you haven't learned yet",
        function(value)
            addon.Config.Set("showUnknownSpells", value)
            if addon.UI.UpdateSpellList then
                addon.UI.UpdateSpellList()
            end
        end,
        16,
        yOffset
    )
    showUnknownCheckbox:SetChecked(addon.Config.Get("showUnknownSpells"))
    
    yOffset = yOffset - 40
    
    -- Sort Known First checkbox
    local sortKnownCheckbox = ConfigUIUtils.CreateCheckbox(
        panel,
        "Sort Known Spells First",
        "Show learned spells at the top of the list",
        function(value)
            addon.Config.Set("sortKnownFirst", value)
            if addon.UI.UpdateSpellList then
                addon.UI.UpdateSpellList()
            end
        end,
        16,
        yOffset
    )
    sortKnownCheckbox:SetChecked(addon.Config.Get("sortKnownFirst"))
    
    yOffset = yOffset - 40
    
    -- Remember Last Category checkbox
    local rememberCategoryCheckbox = ConfigUIUtils.CreateCheckbox(
        panel,
        "Remember Last Category",
        "Remember the last selected category tab when reopening",
        function(value)
            addon.Config.Set("rememberLastCategory", value)
        end,
        16,
        yOffset
    )
    rememberCategoryCheckbox:SetChecked(addon.Config.Get("rememberLastCategory"))
    
    yOffset = yOffset - 40
    
    -- Debug Mode checkbox
    local debugCheckbox = ConfigUIUtils.CreateCheckbox(
        panel,
        "Enable Debug Mode",
        "Show debug messages in chat",
        function(value)
            addon.Config.Set("debugEnabled", value)
            Utils.SetDebugEnabled(value)
        end,
        16,
        yOffset
    )
    debugCheckbox:SetChecked(addon.Config.Get("debugEnabled"))
    
    yOffset = yOffset - 50
    
    -- Reset Position button
    local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetButton:SetSize(140, 22)
    resetButton:SetPoint("TOPLEFT", 16, yOffset)
    resetButton:SetText("Reset Window Position")
    resetButton:SetScript("OnClick", function()
        if addon.MainFrame and addon.MainFrame.frame then
            addon.MainFrame.frame:ClearAllPoints()
            addon.MainFrame.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            addon.Config.SaveWindowPosition()
            Utils.Print("Window position reset to center")
        end
    end)
    
    -- Support section is handled automatically by PeaversCommons
    
    -- Add callbacks
    panel.OnCommit = function() end
    panel.OnDefault = function()
        -- Reset to defaults
        addon.Config.Set("showUnknownSpells", true)
        addon.Config.Set("sortKnownFirst", true)
        addon.Config.Set("rememberLastCategory", false)
        addon.Config.Set("debugEnabled", false)
        
        -- Update checkboxes
        showUnknownCheckbox:SetChecked(true)
        sortKnownCheckbox:SetChecked(true)
        rememberCategoryCheckbox:SetChecked(false)
        debugCheckbox:SetChecked(false)
        
        -- Update UI if needed
        if addon.UI.UpdateSpellList then
            addon.UI.UpdateSpellList()
        end
    end
    panel.OnRefresh = function()
        showUnknownCheckbox:SetChecked(addon.Config.Get("showUnknownSpells"))
        sortKnownCheckbox:SetChecked(addon.Config.Get("sortKnownFirst"))
        rememberCategoryCheckbox:SetChecked(addon.Config.Get("rememberLastCategory"))
        debugCheckbox:SetChecked(addon.Config.Get("debugEnabled"))
    end
    
    return panel
end

function ConfigUI:Initialize()
    self.panel = self:InitializeOptions()
end

function ConfigUI.Open()
    -- Use the stored settings category from PeaversCommons
    if addon.directSettingsCategory then
        Settings.OpenToCategory(addon.directSettingsCategory)
    elseif addon.directCategory then
        -- Fallback to main category
        Settings.OpenToCategory(addon.directCategory)
    elseif Settings and Settings.OpenToCategory then
        -- Last resort fallback
        Settings.OpenToCategory("PeaversHeroPath")
    end
end

addon.ConfigUI = ConfigUI
return ConfigUI