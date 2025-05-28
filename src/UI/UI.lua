local _, addon = ...

local UI = {}

function UI.Initialize()
    -- Create main components
    addon.MainFrame.Create()
    local frame = addon.MainFrame.frame
    
    -- Create search bar
    addon.SearchBar.Create(frame.contentFrame)
    
    -- Create spell list
    addon.SpellList.Create(frame.contentFrame)
    
    -- Set default portrait after everything is initialized
    C_Timer.After(0.1, function()
        addon.MainFrame.SetDefaultPortrait()
    end)
end

function UI.Show()
    addon.MainFrame.Show()
end

function UI.Hide()
    addon.MainFrame.Hide()
end

function UI.Toggle()
    addon.MainFrame.Toggle()
end

function UI.UpdateSpellList(searchQuery)
    local spells
    
    if searchQuery and searchQuery ~= "" then
        spells = addon.HeroPathData.SearchSpells(searchQuery)
    else
        spells = addon.HeroPathData.GetAllSpells()
    end
    
    addon.SpellList.UpdateList(spells)
end

addon.UI = UI
return UI