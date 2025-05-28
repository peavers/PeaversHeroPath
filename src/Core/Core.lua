local _, addon = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons and PeaversCommons.Utils

local Core = {}

-- Create a hidden secure button for casting spells
local secureButton

function Core.Initialize()
    Utils.Debug("PeaversHeroPath Core initializing...")
    
    -- Create saved variables structure
    if not PeaversHeroPathDB then
        PeaversHeroPathDB = {
            config = {},
            version = 1
        }
    end
    
    -- Create secure casting button
    Core.CreateSecureButton()
    
    -- Update player's known spells on login and when learning new spells
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
    frame:RegisterEvent("SPELLS_CHANGED")
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            Core.UpdateKnownSpells()
        elseif event == "LEARNED_SPELL_IN_TAB" or event == "SPELLS_CHANGED" then
            C_Timer.After(0.5, function()
                Core.UpdateKnownSpells()
            end)
        end
    end)
end

function Core.CreateSecureButton()
    if secureButton then return end
    
    -- Create a hidden secure button for spell casting
    secureButton = CreateFrame("Button", "PeaversHeroPathSecureButton", UIParent, "SecureActionButtonTemplate")
    secureButton:Hide()
    secureButton:SetAttribute("type", "spell")
    
    -- Hook script to close UI after casting
    secureButton:HookScript("OnClick", function()
        if addon.UI and addon.UI.Hide then
            C_Timer.After(0.1, function()
                addon.UI.Hide()
            end)
        end
    end)
end

function Core.UpdateKnownSpells()
    Utils.Debug("Updating known Hero Path spells...")
    local knownCount = 0
    
    for _, spell in ipairs(addon.HeroPathData.GetAllSpells()) do
        if addon.HeroPathData.IsSpellKnown(spell.spellId) then
            knownCount = knownCount + 1
        end
    end
    
    Utils.Debug("Found " .. knownCount .. " known Hero Path spells")
end

function Core.CastSpell(spellId, spellName)
    if not addon.HeroPathData.IsSpellKnown(spellId) then
        Utils.Print("You haven't learned this Hero Path spell yet.")
        return false
    end
    
    -- Get spell name if not provided
    local spellDisplayName = spellName
    if not spellDisplayName then
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        spellDisplayName = spellInfo and spellInfo.name
    end
    
    if spellDisplayName then
        -- Create or update a temporary macro to cast the spell
        local macroName = "PeaversHeroPath"
        local macroBody = "/cast " .. spellDisplayName
        
        -- Get the spell texture for the icon
        local spellTexture = C_Spell.GetSpellTexture(spellId)
        local iconTexture = spellTexture or "Interface\\Icons\\spell_arcane_portalundercity"
        
        -- Check if macro exists
        local macroIndex = GetMacroIndexByName(macroName)
        
        if macroIndex == 0 then
            -- Create new macro
            macroIndex = CreateMacro(macroName, iconTexture, macroBody, nil)
            if macroIndex == 0 then
                Utils.Print("Failed to create macro for casting spell")
                return false
            end
        else
            -- Update existing macro
            EditMacro(macroIndex, macroName, iconTexture, macroBody)
        end
        
        -- Close UI first
        if addon.UI and addon.UI.Hide then
            addon.UI.Hide()
        end
        
        -- Run the macro
        RunMacro(macroIndex)
        return true
    else
        Utils.Print("Could not get spell name for ID: " .. spellId)
        return false
    end
end

-- Expose secure button for direct access
function Core.GetSecureButton()
    return secureButton
end

addon.Core = Core
return Core