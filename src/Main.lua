local addonName, addon = ...

-- Check for PeaversCommons
local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons to work properly.")
    return
end

local Utils = PeaversCommons.Utils
local SlashCommands = PeaversCommons.SlashCommands
local Events = PeaversCommons.Events

-- Initialize addon namespace and modules
addon = addon or {}
addon.Core = addon.Core or {}
addon.UI = addon.UI or {}
addon.Config = addon.Config or {}

-- Set global reference for PeaversCommons integration
_G[addonName] = addon

-- Initialize addon using PeaversCommons Events module
Events:Init(addonName, function()
    Utils.Debug(addonName .. " initializing...")
    
    -- Initialize core components
    if addon.Core.Initialize then
        addon.Core.Initialize()
    end
    
    -- Initialize configuration FIRST
    if addon.Config and addon.Config.Initialize then
        addon.Config:Initialize()
    end
    
    -- ConfigUI removed - we only need Macro tab
    
    -- Initialize MacroUI
    if addon.MacroUI and addon.MacroUI.Initialize then
        addon.MacroUI:Initialize()
    end
    
    -- Create initial macro with default icon
    local macroName = "PeaversHeroPath"
    local macroIndex = GetMacroIndexByName(macroName)
    if macroIndex == 0 then
        CreateMacro(macroName, "Interface\\Icons\\spell_arcane_portalundercity", "-- Select a Hero Path spell first", false)
        Utils.Debug("Created initial PeaversHeroPath macro")
    end
    
    -- Initialize UI
    if addon.UI.Initialize then
        addon.UI.Initialize()
    end
    
    -- Register slash commands
    SlashCommands:Register(addonName, "pt", {
        default = function() 
            addon.UI.Toggle() 
        end
    })
    
    SlashCommands:Register(addonName, "travel", {
        default = function() 
            addon.UI.Toggle() 
        end
    })
    
    SlashCommands:Register(addonName, "heropath", {
        default = function() 
            addon.UI.Toggle() 
        end,
        config = function()
            if Settings and Settings.OpenToCategory then
                Settings.OpenToCategory("PeaversHeroPath")
            end
        end
    })
    
    -- Create settings pages after a short delay
    C_Timer.After(0.5, function()
        if PeaversCommons.SettingsUI then
            -- No ConfigUI needed, just register Macro tab
            PeaversCommons.SettingsUI:CreateSettingsPages(
                    addon,
                    "PeaversHeroPath",
                    "Peavers Hero Path",
                    "Displays Hero Path portal spells with search functionality",
                    {
                        "/pt, /travel, /heropath - Toggle the Hero Path window",
                        "/heropath config - Open settings"
                    }
                )
                
                -- Register the Macro subcategory after the main settings are created
                if addon.MacroUI and addon.MacroUI.panel and addon.directCategory then
                    local macroCategory = Settings.RegisterCanvasLayoutSubcategory(
                        addon.directCategory,
                        addon.MacroUI.panel,
                        "Macro"
                    )
                    addon.directMacroCategory = macroCategory
                end
        end
    end)
    
    Utils.Print(addonName .. " loaded. Use /pt or /travel to open.")
end, {
    announceMessage = "Use |cff3abdf7/pt|r or |cff3abdf7/travel|r to open Hero Path portals"
})