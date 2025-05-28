local _, addon = ...

-- Access PeaversCommons from global namespace
local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r PeaversHeroPath requires PeaversCommons to work properly.")
    return
end

local defaults = {
    windowPosition = {
        point = "CENTER",
        relativeTo = "UIParent",
        relativePoint = "CENTER",
        xOfs = 0,
        yOfs = 0
    },
    showUnknownSpells = true,
    sortKnownFirst = true,
    rememberLastCategory = false,
    lastCategory = "All",
    debugEnabled = false
}

-- Create a new config instance using PeaversCommons ConfigManager
local Config = PeaversCommons.ConfigManager:New(
    "PeaversHeroPath",
    defaults,
    {
        savedVariablesName = "PeaversHeroPathDB"
    }
)

-- Override Initialize to include position restoration
local originalInitialize = Config.Initialize
function Config:Initialize()
    -- Call the original initialize method
    originalInitialize(self)
    
    -- Restore window position
    self:RestoreWindowPosition()
end

-- Add custom Get method (ConfigManager provides GetSetting)
function Config:Get(key)
    if self.GetSetting then
        return self:GetSetting(key, defaults[key])
    else
        -- Fallback to defaults if ConfigManager not initialized yet
        return defaults[key]
    end
end

-- Add custom Set method (ConfigManager provides UpdateSetting)
function Config:Set(key, value)
    if self.UpdateSetting then
        self:UpdateSetting(key, value)
    else
        -- Fallback: store temporarily if ConfigManager not initialized yet
        defaults[key] = value
    end
end

function Config:RestoreWindowPosition()
    if addon.MainFrame and addon.MainFrame.frame then
        local pos = self:Get("windowPosition")
        if pos then
            addon.MainFrame.frame:ClearAllPoints()
            addon.MainFrame.frame:SetPoint(pos.point, pos.relativeTo, pos.relativePoint, pos.xOfs, pos.yOfs)
        end
    end
end

function Config:SaveWindowPosition()
    if addon.MainFrame and addon.MainFrame.frame then
        local point, _, relativePoint, xOfs, yOfs = addon.MainFrame.frame:GetPoint()
        self:Set("windowPosition", {
            point = point,
            relativeTo = "UIParent",
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs
        })
    end
end

addon.Config = Config
return Config