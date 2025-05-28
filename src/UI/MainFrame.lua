local _, addon = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons and PeaversCommons.Utils

local MainFrame = {}
local frame

function MainFrame.Create()
    if frame then return frame end
    
    -- Create main frame using native Blizzard dialog styling
    frame = CreateFrame("Frame", "PeaversHeroPathFrame", UIParent, "PortraitFrameTemplate")
    frame:SetSize(420, 620)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if addon.Config and addon.Config.SaveWindowPosition then
            addon.Config:SaveWindowPosition()
        end
    end)
    
    -- Set title - create our own title if needed
    local titleText = frame.TitleText or (frame.TitleContainer and frame.TitleContainer.TitleText)
    if not titleText and frame.TitleContainer then
        -- Create title text in the TitleContainer
        titleText = frame.TitleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleText:SetPoint("CENTER")
        titleText:SetTextColor(1, 0.82, 0)  -- Blizzard gold
    end
    
    if titleText then
        titleText:SetText("Peavers Hero Path")
    end
    
    -- Set initial portrait - try different possible portrait locations
    local portrait = nil
    if frame.PortraitContainer then
        -- Look for portrait in PortraitContainer
        portrait = frame.PortraitContainer.portrait or frame.PortraitContainer.Portrait
        if not portrait then
            -- Create portrait texture if container exists but no portrait
            portrait = frame.PortraitContainer:CreateTexture(nil, "ARTWORK")
            portrait:SetAllPoints()
        end
    elseif frame.portrait then
        portrait = frame.portrait
    end
    
    if portrait then
        portrait:SetTexture("Interface\\Icons\\spell_arcane_portalundercity")
        frame.portraitTexture = portrait
    end
    
    -- Header info positioned below the title area
    local headerContainer = CreateFrame("Frame", nil, frame)
    headerContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -65)  -- Below title area
    headerContainer:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -25, -65)
    headerContainer:SetHeight(25)
    
    local headerText = headerContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerText:SetPoint("CENTER", 0, 0)
    headerText:SetText("Select a Hero Path portal to update your macro")
    headerText:SetTextColor(1, 0.82, 0)  -- Blizzard gold color
    
    -- Cooldown bar container (modern cast bar style)
    local cooldownContainer = CreateFrame("Frame", nil, frame)
    cooldownContainer:SetPoint("TOPLEFT", headerContainer, "BOTTOMLEFT", 0, -8)
    cooldownContainer:SetPoint("TOPRIGHT", headerContainer, "BOTTOMRIGHT", 0, -8)
    cooldownContainer:SetHeight(18)
    
    -- Cooldown bar background (modern cast bar style)
    local cooldownBg = cooldownContainer:CreateTexture(nil, "BACKGROUND")
    cooldownBg:SetAllPoints()
    cooldownBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    cooldownBg:SetVertexColor(0.15, 0.15, 0.15, 0.8)
    
    -- Cooldown bar border (manual creation)
    local cooldownBorder = cooldownContainer:CreateTexture(nil, "BORDER")
    cooldownBorder:SetAllPoints()
    cooldownBorder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border")
    cooldownBorder:SetTexCoord(0, 1, 0, 1)
    
    -- Cooldown bar (modern cast bar style)
    local cooldownBar = cooldownContainer:CreateTexture(nil, "ARTWORK")
    cooldownBar:SetPoint("LEFT", 2, 0)
    cooldownBar:SetHeight(14)
    cooldownBar:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    cooldownBar:SetVertexColor(1.0, 0.7, 0.0, 1.0)  -- Golden/orange color like cast bars
    
    -- Cooldown text (modern cast bar style)
    local cooldownText = cooldownContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cooldownText:SetPoint("CENTER")
    cooldownText:SetTextColor(1, 1, 1)
    cooldownText:SetShadowOffset(1, -1)
    cooldownText:SetShadowColor(0, 0, 0, 1)
    
    -- Content frame using native Blizzard inset styling - adjusted for cooldown bar
    local contentFrame = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    contentFrame:SetPoint("TOPLEFT", cooldownContainer, "BOTTOMLEFT", -25, -5)
    contentFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    
    frame.headerContainer = headerContainer
    frame.cooldownContainer = cooldownContainer
    frame.cooldownBar = cooldownBar
    frame.cooldownText = cooldownText
    frame.contentFrame = contentFrame
    
    -- Store frame reference in MainFrame
    MainFrame.frame = frame
    
    -- Hide by default
    frame:Hide()
    
    -- Add to special frames for ESC key handling
    tinsert(UISpecialFrames, "PeaversHeroPathFrame")
    
    return frame
end

-- Portal count display removed for cleaner interface

-- Status display removed for cleaner interface

function MainFrame.UpdatePortrait(iconTexture)
    if MainFrame.frame and MainFrame.frame.portraitTexture and iconTexture then
        MainFrame.frame.portraitTexture:SetTexture(iconTexture)
    end
end

function MainFrame.UpdateCooldown()
    if not MainFrame.frame or not MainFrame.frame.cooldownBar then
        return
    end
    
    -- Check for any Hero Path spell cooldown
    local allSpells = addon.HeroPathData.GetAllSpells()
    local longestCooldown = nil
    local longestRemaining = 0
    
    for _, spell in ipairs(allSpells) do
        local cooldownInfo = C_Spell.GetSpellCooldown(spell.spellId)
        if cooldownInfo and cooldownInfo.duration > 0 then
            local remaining = cooldownInfo.startTime + cooldownInfo.duration - GetTime()
            if remaining > longestRemaining then
                longestCooldown = cooldownInfo
                longestRemaining = remaining
            end
        end
    end
    
    if longestCooldown and longestRemaining > 0 then
        -- Show cooldown
        local percentage = longestRemaining / longestCooldown.duration
        local containerWidth = MainFrame.frame.cooldownContainer:GetWidth()
        MainFrame.frame.cooldownBar:SetWidth((containerWidth - 4) * percentage)  -- Account for border padding
        
        -- Format time (hours until last hour, then minutes)
        local timeText
        if longestRemaining >= 3600 then  -- 1 hour or more
            timeText = string.format("%.1fh", longestRemaining / 3600)
        elseif longestRemaining >= 60 then  -- 1 minute to 59 minutes
            timeText = string.format("%.0fm", longestRemaining / 60)
        else  -- Less than 1 minute
            timeText = string.format("%.0fs", longestRemaining)
        end
        MainFrame.frame.cooldownText:SetText("Hero Path: " .. timeText)
        MainFrame.frame.cooldownContainer:Show()
        return
    end
    
    -- No cooldown - hide the bar
    MainFrame.frame.cooldownContainer:Hide()
end

function MainFrame.StartCooldownTimer()
    if MainFrame.cooldownTimer then
        MainFrame.cooldownTimer:Cancel()
    end
    
    MainFrame.cooldownTimer = C_Timer.NewTicker(0.1, function()
        MainFrame.UpdateCooldown()
    end)
end

function MainFrame.StopCooldownTimer()
    if MainFrame.cooldownTimer then
        MainFrame.cooldownTimer:Cancel()
        MainFrame.cooldownTimer = nil
    end
end

function MainFrame.SetDefaultPortrait()
    -- Set portrait to first known spell, or first spell overall
    local allSpells = addon.HeroPathData.GetAllSpells()
    local defaultSpell = nil
    
    -- Try to find first known spell
    for _, spell in ipairs(allSpells) do
        if addon.HeroPathData.IsSpellKnown(spell.spellId) then
            defaultSpell = spell
            break
        end
    end
    
    -- If no known spells, use first spell
    if not defaultSpell and #allSpells > 0 then
        defaultSpell = allSpells[1]
    end
    
    -- Set portrait
    if defaultSpell then
        local iconTexture = defaultSpell.icon or C_Spell.GetSpellTexture(defaultSpell.spellId)
        MainFrame.UpdatePortrait(iconTexture)
    end
end

function MainFrame.Show()
    if not MainFrame.frame then
        MainFrame.Create()
    end
    
    -- Restore saved position
    if addon.Config and addon.Config.RestoreWindowPosition then
        addon.Config:RestoreWindowPosition()
    end
    
    MainFrame.frame:Show()
    
    -- Start cooldown timer
    MainFrame.StartCooldownTimer()
    
    -- Update the spell list when showing
    if addon.UI.UpdateSpellList then
        addon.UI.UpdateSpellList()
    end
end

function MainFrame.Hide()
    if MainFrame.frame then
        MainFrame.frame:Hide()
    end
    
    -- Stop cooldown timer when hiding
    MainFrame.StopCooldownTimer()
end

function MainFrame.Toggle()
    if not MainFrame.frame then
        MainFrame.Create()
    end
    
    if MainFrame.frame:IsShown() then
        MainFrame.Hide()
    else
        MainFrame.Show()
    end
end

addon.MainFrame = MainFrame
return MainFrame