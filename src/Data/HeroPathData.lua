local _, addon = ...

local HeroPathData = {}

HeroPathData.Spells = {
    -- The War Within Dungeons
    {
        name = "The Rookery",
        spellId = 445269,
        expansion = "The War Within",
        icon = 5899330,
        zone = "Isle of Dorn",
        description = "Hero Path to The Rookery dungeon"
    },
    {
        name = "The Stonevault",
        spellId = 445416,
        expansion = "The War Within",
        icon = 5899332,
        zone = "The Ringing Deeps",
        description = "Hero Path to The Stonevault dungeon"
    },
    {
        name = "Priory of the Sacred Flame",
        spellId = 445414,
        expansion = "The War Within",
        icon = 5899329,
        zone = "Hallowfall",
        description = "Hero Path to Priory of the Sacred Flame dungeon"
    },
    {
        name = "City of Threads",
        spellId = 445424,
        expansion = "The War Within",
        icon = 5899324,
        zone = "Azj-Kahet",
        description = "Hero Path to City of Threads dungeon"
    },
    {
        name = "Cinderbrew Meadery",
        spellId = 445440,
        expansion = "The War Within",
        icon = 5899323,
        zone = "The Ringing Deeps",
        description = "Hero Path to Cinderbrew Meadery dungeon"
    },
    {
        name = "The Dawnbreaker",
        spellId = 445443,
        expansion = "The War Within",
        icon = 5899325,
        zone = "Hallowfall",
        description = "Hero Path to The Dawnbreaker dungeon"
    },
    {
        name = "Ara-Kara, City of Echoes",
        spellId = 445418,
        expansion = "The War Within",
        icon = 5899322,
        zone = "Azj-Kahet",
        description = "Hero Path to Ara-Kara, City of Echoes dungeon"
    },
    {
        name = "Darkflame Cleft",
        spellId = 445444,
        expansion = "The War Within",
        icon = 5899326,
        zone = "Isle of Dorn",
        description = "Hero Path to Darkflame Cleft dungeon"
    },
    
    -- Dragonflight Dungeons
    {
        name = "Algeth'ar Academy",
        spellId = 395160,
        expansion = "Dragonflight",
        icon = 4622470,
        zone = "Thaldraszus",
        description = "Hero Path to Algeth'ar Academy dungeon"
    },
    {
        name = "Ruby Life Pools",
        spellId = 393279,
        expansion = "Dragonflight",
        icon = 4622472,
        zone = "The Waking Shores",
        description = "Hero Path to Ruby Life Pools dungeon"
    },
    {
        name = "The Nokhud Offensive",
        spellId = 393262,
        expansion = "Dragonflight",
        icon = 4622471,
        zone = "Ohn'ahran Plains",
        description = "Hero Path to The Nokhud Offensive dungeon"
    },
    {
        name = "The Azure Vault",
        spellId = 393273,
        expansion = "Dragonflight",
        icon = 4622466,
        zone = "The Azure Span",
        description = "Hero Path to The Azure Vault dungeon"
    },
    {
        name = "Brackenhide Hollow",
        spellId = 393267,
        expansion = "Dragonflight",
        icon = 4622467,
        zone = "The Azure Span",
        description = "Hero Path to Brackenhide Hollow dungeon"
    },
    {
        name = "Halls of Infusion",
        spellId = 393256,
        expansion = "Dragonflight",
        icon = 4622468,
        zone = "Thaldraszus",
        description = "Hero Path to Halls of Infusion dungeon"
    },
    {
        name = "Neltharus",
        spellId = 393276,
        expansion = "Dragonflight",
        icon = 4622469,
        zone = "The Waking Shores",
        description = "Hero Path to Neltharus dungeon"
    },
    {
        name = "Uldaman: Legacy of Tyr",
        spellId = 393222,
        expansion = "Dragonflight",
        icon = 4622473,
        zone = "Badlands",
        description = "Hero Path to Uldaman: Legacy of Tyr dungeon"
    },
    
    -- Current Season M+ Dungeons (with Hero Paths)
    {
        name = "Grim Batol",
        spellId = 424142,
        expansion = "Cataclysm",
        icon = 237271,
        zone = "Twilight Highlands",
        description = "Hero Path to Grim Batol dungeon"
    },
    {
        name = "Siege of Boralus",
        spellId = 424187,
        expansion = "Battle for Azeroth",
        icon = 2065567,
        zone = "Tiragarde Sound",
        description = "Hero Path to Siege of Boralus dungeon"
    },
    {
        name = "Mists of Tirna Scithe",
        spellId = 354462,
        expansion = "Shadowlands",
        icon = 3636839,
        zone = "Ardenweald",
        description = "Hero Path to Mists of Tirna Scithe dungeon"
    },
    {
        name = "The Necrotic Wake",
        spellId = 354464,
        expansion = "Shadowlands",
        icon = 3636846,
        zone = "Bastion",
        description = "Hero Path to The Necrotic Wake dungeon"
    }
}

function HeroPathData.GetAllSpells()
    return HeroPathData.Spells
end

function HeroPathData.SearchSpells(query)
    if not query or query == "" then
        return HeroPathData.Spells
    end
    
    query = query:lower()
    local results = {}
    
    for _, spell in ipairs(HeroPathData.Spells) do
        if spell.name:lower():find(query, 1, true) or 
           spell.expansion:lower():find(query, 1, true) or
           spell.zone:lower():find(query, 1, true) or
           (spell.description and spell.description:lower():find(query, 1, true)) then
            table.insert(results, spell)
        end
    end
    
    return results
end

function HeroPathData.IsSpellKnown(spellId)
    return IsSpellKnown(spellId) or IsPlayerSpell(spellId)
end

addon.HeroPathData = HeroPathData
return HeroPathData