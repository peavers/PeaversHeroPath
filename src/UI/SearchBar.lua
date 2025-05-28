local _, addon = ...

local SearchBar = {}
local searchBox

function SearchBar.Create(parent)
    if searchBox then return searchBox end
    
    -- Create search container using native styling
    local searchContainer = CreateFrame("Frame", nil, parent)
    searchContainer:SetHeight(35)
    searchContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    searchContainer:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, -10)
    
    -- Create search box with native Blizzard styling
    searchBox = CreateFrame("EditBox", "PeaversHeroPathSearchBox", searchContainer, "BagSearchBoxTemplate")
    searchBox:SetPoint("CENTER")
    searchBox:SetSize(300, 20)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(50)
    
    -- Placeholder text
    searchBox:SetScript("OnEditFocusGained", function(self)
        if self:GetText() == "" then
            self.Instructions:SetText("")
        end
    end)
    
    searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self.Instructions:SetText("Search by dungeon name, zone, or expansion...")
        end
    end)
    
    -- Set initial placeholder
    searchBox.Instructions:SetText("Search by dungeon name, zone, or expansion...")
    searchBox.Instructions:SetTextColor(0.6, 0.6, 0.6)
    
    -- Handle search input
    searchBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            SearchBar.OnSearchTextChanged(self:GetText())
        end
    end)
    
    -- Handle Enter key
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    
    -- Handle Escape key
    searchBox:SetScript("OnEscapePressed", function(self)
        if self:GetText() ~= "" then
            self:SetText("")
            SearchBar.OnSearchTextChanged("")
        else
            self:ClearFocus()
        end
    end)
    
    searchBox.container = searchContainer
    return searchBox
end

function SearchBar.OnSearchTextChanged(text)
    -- Update the spell list with search results
    if addon.UI and addon.UI.UpdateSpellList then
        addon.UI.UpdateSpellList(text)
    end
end

function SearchBar.Clear()
    if searchBox then
        searchBox:SetText("")
        searchBox:ClearFocus()
    end
end

addon.SearchBar = SearchBar
return SearchBar