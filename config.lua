Config = {}

-- ========================================
--  General Settings
-- ========================================
Config.debug = false

-- Notification routing: 'rtx_notify' uses TriggerEvent('rtx_notify:Notify', ...),
-- 'ox_lib' uses lib.notify(). Set to 'ox_lib' for servers without rtx_notify.
Config.notifySystem = 'ox_lib'    -- 'ox_lib' (default) or 'rtx_notify' if installed

Config.maxActivePets = 2          -- max pets a player can have spawned at once
Config.dataUpdateInterval = 10    -- seconds between server XP/food/thirst ticks
Config.itemCooldown = 1           -- seconds between consecutive item uses
Config.callDuration = 2           -- seconds for whistle/spawn progress bar
Config.despawnDuration = 3        -- seconds for despawn progress bar
Config.customizeAfterPurchase = true -- open customization menu after buying a pet

Config.petMenuKeybind = 'RBRACKET' -- key to open pet companion menu (was O, conflicted with dispatch)

Config.chaseDistance = 50.0       -- max distance pet will chase a target
Config.chaseIndicator = true      -- show indicator when pet is chasing

Config.blip = {
    enabled = true,
    sprite = 442,
    colour = 2,
    shortRange = false,
}

Config.nameTag = {
    enabled = true,
    distance = 15.0,          -- max draw distance
    scale = 0.35,
    showLevel = true,          -- show level title under name
}

Config.petEmotes = {
    happy = { mood = 1, vocalization = 'bark',  anim = 'bark' },
    angry = { mood = 0, vocalization = 'growl', anim = 'bark' },
    sad   = { mood = 3, vocalization = 'whine' },
    bark  = { mood = 1, vocalization = 'bark',  anim = 'bark' },
    sit   = { anim = 'sit' },
    sleep = { anim = 'sleep' },
    dance = { mood = 1, vocalization = 'bark',  trick = 'beg' },     -- trick dance (beg loop)
    paw   = { mood = 1,                         trick = 'paw' },     -- paw shake
    lay   = { anim = 'sleep' },                                      -- lay down (reuses sleep)
    fetch = { mood = 1, vocalization = 'bark',  special = 'fetch' }, -- ball throw + retrieve
}

-- ========================================
--  Pet Carry
-- ========================================
Config.carry = {
    enabled = true,
    allowedSizes = { 'small', 'medium' },  -- large pets are too big
    playerBone = 24818,    -- SKEL_Spine3
    offset = vec3(0.05, 0.15, 0.40),
    rotation = vec3(0.0, 0.0, 0.0),
}

Config.guard = {
    enabled = true,
    radius = 10.0,              -- default guard radius in meters
    checkInterval = 500,        -- ms between enforcement checks
    attackPlayers = false,      -- true = attack player peds too, false = NPCs only
    speciesAllowed = { 'dog', 'wild' },
    notifyOwner = true,
    combatAbility = 100,
    combatRange = 2,            -- 0=near, 1=medium, 2=far
    combatMovement = 3,         -- 0=stationary, 1=defensive, 2=offensive, 3=suicidal
}

Config.aggro = {
    enabled = true,
    checkInterval = 500,            -- ms between threat scans
    detectionRange = 25.0,          -- meters from owner to detect threats
    attackPlayers = true,           -- true = aggro on player attackers too
    speciesAllowed = { 'dog', 'wild' },
    notifyOwner = true,
    -- NOTE: Aggro now auto-starts on spawn for dogs/wild species.
    -- The menu toggle still exists for manual on/off if someone wants to disable it.
}

Config.stressRelief = {
    enabled = true,              -- set true if you have a HUD with stress mechanics
    event = 'hud:server:RelieveStress',
    amount = { min = 12, max = 24 },
}

-- ========================================
--  Stray / Wild Animal Taming
-- ========================================
Config.strays = {
    enabled = true,
    trustThreshold = 100,         -- total trust needed to tame
    trustPerFeed = 20,            -- trust gained per feed
    feedCooldown = 300,           -- seconds between feeds (per player per stray)
    feedItem = 'murderface_food', -- item consumed when feeding
    feedRadius = 3.0,             -- max interaction distance
    respawnTime = 3600,           -- seconds before stray reappears after being tamed

    spawnPoints = {
        {
            id = 'stray_sandy_1',
            coords = vector4(1690.0, 4785.0, 41.9, 180.0),
            model = 'A_C_shepherd',
            item = 'murderface_shepherd',
            label = 'Stray German Shepherd',
            spawnChance = 0.6,
            rareCoat = 'white',
        },
        {
            id = 'stray_paleto_1',
            coords = vector4(-292.0, 6237.0, 31.5, 90.0),
            model = 'A_C_Husky',
            item = 'murderface_husky',
            label = 'Stray Husky',
            spawnChance = 0.4,
            rareCoat = nil,
        },
        {
            id = 'stray_city_1',
            coords = vector4(200.0, -1660.0, 29.3, 0.0),
            model = 'A_C_Rottweiler',
            item = 'murderface_rottweiler',
            label = 'Stray Rottweiler',
            spawnChance = 0.3,
            rareCoat = 'darkBrown',
        },
    },
}

-- ========================================
--  Breeding / Dog House
-- ========================================
Config.breeding = {
    enabled = true,
    propModel = 'prop_doghouse_01',       -- GTA V native dog house prop
    minBreedLevel = 10,                   -- both parents must be at least this level
    breedingCooldownHours = 24,           -- hours before a pet can breed again (real time)
    maxDoghousesPerPlayer = 1,            -- only one placed at a time
    restBonusRadius = 15.0,               -- meters; pets within this get rest bonus
    placementMaxDistance = 50.0,          -- max raycast distance during placement

    restBonus = {
        foodDrainMult = 0.5,              -- 50% less food drain
        thirstIncreaseMult = 0.5,         -- 50% less thirst increase
        healthRegenBonus = 1.0,           -- bonus HP regen per tick
    },

    offspring = {
        inheritSpecialization = false,    -- offspring starts with no specialization
        startLevel = 0,
    },

    speciesAllowed = { 'dog' },           -- only dogs can breed (need a dog house)
}

-- ========================================
--  Balance / Progression
-- ========================================
Config.balance = {
    maxLevel = 50,

    afk = {
        resetAfter = 120,         -- seconds before AFK timer resets
        wanderInterval = 15,      -- seconds before idle pet starts wandering (was 60)
        animInterval = 25,        -- seconds before idle pet plays random anim (was 90)
    },

    -- Natural companion behavior — pets act alive without player input
    ambient = {
        enabled = true,
        idleThreshold = 8,             -- seconds player must be stopped before pet idles
        vocalizeChance = 0.08,         -- chance per tick (1s) to bark/whine randomly
        sniffChance = 0.04,            -- chance per tick to play sniff/wander animation
        reactToNearbyPeds = true,      -- bark at strangers who get close
        nearbyPedRadius = 5.0,         -- meters — bark at peds this close
        nearbyPedCooldown = 30000,     -- ms before barking at same area again
        autoDefend = true,             -- pet auto-attacks anyone who damages owner (no toggle needed)
        autoDefendMinLevel = 0,        -- any pet defends (was 10) — low level = weaker
        cowerOnGunshots = true,        -- small pets cower when nearby gunshots
        gunshotRadius = 30.0,          -- meters
        sprintExcitement = true,       -- pet barks excitedly when owner sprints
        petToPetInteract = true,       -- pets sniff/bark/play when near other pets
        petToPetCooldown = 20000,      -- ms between pet-to-pet interactions
        petToPetRadius = 6.0,          -- meters to detect other companion pets
        waterReactions = true,         -- pets react to entering/leaving water
        waterCooldown = 15000,         -- ms between water reactions
    },

    food = {
        feedAmount = 50,          -- hunger restored per food item
        decreasePerTick = 0.02,   -- hunger lost per server tick (was 0.1 — pets barely get hungry)
        healthDrainWhenStarving = 0.02, -- HP lost per tick at 0 food (very slow drain)
    },

    thirst = {
        increasePerTick = 0.002,  -- thirst gained per server tick (was 0.01 — near-zero)
        reductionPerDrink = 25,   -- thirst reduced per drink action
        healthDrainWhenDehydrated = 0.02, -- HP lost per tick at 100 thirst (very slow)
    },
}

-- ========================================
--  XP Awards (per action)
-- ========================================
Config.xp = {
    passive    = 35,   -- base XP per passive tick (was 10 — pets level up by just hanging out)
    huntKill   = 50,
    petting    = 25,   -- was 15
    trick      = 15,   -- was 10
    feeding    = 20,
    watering   = 15,
    k9Search   = 40,
    healing    = 10,
    guarding   = 10,   -- was 5
    tracking   = 30,
    defending  = 35,   -- was 25
}

-- Seconds between XP awards for the same activity (prevents spam)
Config.activityCooldowns = {
    huntKill = 30,
    petting  = 60,
    trick    = 15,
    k9Search = 30,
    guarding = 60,
    tracking = 30,
    defending = 30,
}

-- ========================================
--  Progression / Level-Gated Unlocks
-- ========================================
Config.progression = {
    minHuntLevel      = 3,    -- was 5 — hunting is a natural dog behavior
    minK9Level        = 10,
    healthRegenLevel  = 3,    -- was 5 — pets heal naturally
    healthRegenAmount = 1.0,
    followSpeed = {
        { minLevel = 0,  speed = 3.0 },
        { minLevel = 10, speed = 4.0 },
        { minLevel = 25, speed = 5.0 },
    },
    -- Movement rate multiplier (SetPedMoveRateOverride) — makes pets physically faster
    -- 1.0 = normal GTA speed, 1.3 = realistic dog, 1.6 = sprint catch-up
    moveRate = {
        idle     = 1.0,   -- standing near player
        walking  = 1.2,   -- player walking
        jogging  = 1.35,  -- player jogging
        sprint   = 1.5,   -- player sprinting
        catchUp  = 1.8,   -- pet is far behind (>10m), needs to close gap
    },
    -- When sprinting, pet runs AHEAD of the player instead of behind
    sprintAhead = true,
    minGuardLevel          = 5,   -- was 10 — dogs guard naturally, just weaker at low level
    minAggroLevel          = 0,   -- was 10 — auto-defense is always on (scaled by level)
    minSpecializationLevel = 20,
    milestones = { 10, 25, 50 },
}

Config.trickLevels = {
    sit       = 0,
    beg       = 5,
    paw       = 10,
    play_dead = 20,
}

Config.levelTitles = {
    { maxLevel = 5,  title = 'Puppy' },
    { maxLevel = 15, title = 'Trained' },
    { maxLevel = 30, title = 'Veteran' },
    { maxLevel = 49, title = 'Elite' },
    { maxLevel = 50, title = 'Legendary' },
}

-- ========================================
--  Specializations
--  Unlocked at Config.progression.minSpecializationLevel.
--  Each path modifies existing systems via multipliers.
-- ========================================
Config.specializations = {
    guardian = {
        label = 'Guardian',
        icon = 'shield-halved',
        iconColor = '#e03131',
        description = 'Larger guard radius, enhanced combat ability.',
        guardRadiusMult = 1.5,       -- 50% larger guard radius
        combatAbilityBonus = 50,     -- added to base combat ability
    },
    tracker = {
        label = 'Tracker',
        icon = 'location-crosshairs',
        iconColor = '#228be6',
        description = 'Detect and highlight nearby peds and animals.',
        trackRadius = 50.0,          -- detection range in meters
        markerDuration = 10000,      -- ms markers stay visible
    },
    companion = {
        label = 'Companion',
        icon = 'heart',
        iconColor = '#e64980',
        description = 'Better stress relief, faster regen, bonus XP.',
        stressReliefMult = 2.0,      -- 2x stress relief
        healthRegenMult = 2.0,       -- 2x health regen rate
        xpBonusMult = 1.25,          -- 25% bonus passive XP
    },
}

-- ========================================
--  Shared Helpers (available on client + server)
-- ========================================

--- XP threshold for a given level (quadratic curve)
---@param level number
---@return number
function Config.xpForLevel(level)
    if level <= 0 then return 0 end
    return 75 + (level * level * 15)
end

--- Lookup level title from Config.levelTitles
---@param level number
---@return string
function Config.getLevelTitle(level)
    for _, t in ipairs(Config.levelTitles) do
        if level <= t.maxLevel then return t.title end
    end
    return 'Legendary'
end

--- Get follow speed for a given pet level
---@param level number
---@return number speed
function Config.getFollowSpeed(level)
    local speed = Config.progression.followSpeed[1].speed
    for _, tier in ipairs(Config.progression.followSpeed) do
        if level >= tier.minLevel then
            speed = tier.speed
        end
    end
    return speed
end

-- ========================================
--  Pets
--  Each entry defines a pet with structured traits.
--  animClass maps to the animation system (shared/animations.lua)
--  Boolean fields control per-pet feature availability.
-- ========================================

Config.pets = {
    -- ===== Large Dogs =====
    {
        model    = 'A_C_Husky',
        item     = 'murderface_husky',
        label    = 'Husky',
        maxHealth = 700,
        price    = 12000,
        canHunt  = true,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'A_C_shepherd',
        item     = 'murderface_shepherd',
        label    = 'German Shepherd',
        maxHealth = 500,
        price    = 8000,
        canHunt  = true,
        isK9     = true,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'A_C_Rottweiler',
        item     = 'murderface_rottweiler',
        label    = 'Rottweiler',
        maxHealth = 600,
        price    = 10000,
        canHunt  = true,
        isK9     = true,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'A_C_Retriever',
        item     = 'murderface_retriever',
        label    = 'Golden Retriever',
        maxHealth = 600,
        price    = 7500,
        canHunt  = true,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'a_c_chop_02',
        item     = 'murderface_chop',
        label    = 'Chop',
        maxHealth = 600,
        price    = 15000,
        canHunt  = true,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },

    -- ===== Small Dogs =====
    {
        model    = 'A_C_Westy',
        item     = 'murderface_westy',
        label    = 'Westie',
        maxHealth = 350,
        price    = 2500,
        canHunt  = false,
        isK9     = false,
        animClass = 'small_dog',
        size     = 'small',
        species  = 'dog',
        canPet   = false,
        canTrick = false,
        icon     = 'dog',
    },
    {
        model    = 'A_C_Pug',
        item     = 'murderface_pug',
        label    = 'Pug',
        maxHealth = 350,
        price    = 3000,
        canHunt  = false,
        isK9     = false,
        animClass = 'small_dog',
        size     = 'small',
        species  = 'dog',
        canPet   = false,
        canTrick = false,
        icon     = 'dog',
    },
    {
        model    = 'A_C_Poodle',
        item     = 'murderface_poodle',
        label    = 'Poodle',
        maxHealth = 350,
        price    = 4000,
        canHunt  = false,
        isK9     = false,
        animClass = 'small_dog',
        size     = 'small',
        species  = 'dog',
        canPet   = false,
        canTrick = false,
        icon     = 'dog',
    },

    -- ===== Cats =====
    {
        model    = 'A_C_Cat_01',
        item     = 'murderface_cat',
        label    = 'House Cat',
        maxHealth = 350,
        price    = 2000,
        canHunt  = false,
        isK9     = false,
        animClass = 'cat',
        size     = 'small',
        species  = 'cat',
        canPet   = false,
        canTrick = false,
        icon     = 'cat',
    },

    -- ===== Big Cats / Wild =====
    {
        model    = 'A_C_Panther',
        item     = 'murderface_panther',
        label    = 'Black Panther',
        maxHealth = 700,
        price    = 50000,
        canHunt  = true,
        isK9     = false,
        animClass = 'cougar',
        size     = 'large',
        species  = 'wild',
        canPet   = false,
        canTrick = false,
        icon     = 'cat',
    },
    {
        model    = 'A_C_MtLion',
        item     = 'murderface_mtlion',
        label    = 'Mountain Lion',
        maxHealth = 700,
        price    = 40000,
        canHunt  = true,
        isK9     = false,
        animClass = 'cougar',
        size     = 'large',
        species  = 'wild',
        canPet   = false,
        canTrick = false,
        icon     = 'cat',
    },
    {
        model    = 'A_C_Coyote',
        item     = 'murderface_coyote',
        label    = 'Coyote',
        maxHealth = 700,
        price    = 15000,
        canHunt  = false,
        isK9     = false,
        animClass = 'cougar',
        size     = 'medium',
        species  = 'wild',
        canPet   = false,
        canTrick = false,
        icon     = 'paw',
    },

    -- ===== Small Animals =====
    {
        model    = 'A_C_Hen',
        item     = 'murderface_hen',
        label    = 'Chicken',
        maxHealth = 400,
        price    = 500,
        canHunt  = false,
        isK9     = false,
        animClass = nil,
        size     = 'small',
        species  = 'bird',
        canPet   = false,
        canTrick = false,
        icon     = 'kiwi-bird',
    },
    {
        model    = 'A_C_Rabbit_01',
        item     = 'murderface_rabbit',
        label    = 'Rabbit',
        maxHealth = 400,
        price    = 1000,
        canHunt  = false,
        isK9     = false,
        animClass = nil,
        size     = 'small',
        species  = 'small',
        canPet   = false,
        canTrick = false,
        icon     = 'paw',
    },

    -- ===== Primates =====
    {
        model    = 'a_c_chimp_02',
        item     = 'murderface_chimp',
        label    = 'Chimpanzee',
        maxHealth = 500,
        price    = 75000,
        canHunt  = false,
        isK9     = false,
        animClass = 'primate',
        size     = 'medium',
        species  = 'primate',
        canPet   = false,
        canTrick = false,
        icon     = 'paw',
    },
    {
        model    = 'a_c_rhesus',
        item     = 'murderface_rhesus',
        label    = 'Rhesus Monkey',
        maxHealth = 350,
        price    = 35000,
        canHunt  = false,
        isK9     = false,
        animClass = 'primate',
        size     = 'small',
        species  = 'primate',
        canPet   = false,
        canTrick = false,
        icon     = 'paw',
    },

    -- ===== Addon Breeds (dusa_addonpets streaming) =====
    {
        model    = 'dusa_doberman',
        item     = 'murderface_doberman',
        label    = 'Doberman',
        maxHealth = 650,
        price    = 8000,
        canHunt  = true,
        isK9     = true,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'dusa_cane',
        item     = 'murderface_canecorso',
        label    = 'Cane Corso',
        maxHealth = 700,
        price    = 7500,
        canHunt  = true,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'dusa_englishbulldog',
        item     = 'murderface_englishbulldog',
        label    = 'English Bulldog',
        maxHealth = 500,
        price    = 6500,
        canHunt  = false,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'medium',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'a_c_poodle_2',
        item     = 'murderface_poodle2',
        label    = 'Toy Poodle',
        maxHealth = 350,
        price    = 4500,
        canHunt  = false,
        isK9     = false,
        animClass = 'small_dog',
        size     = 'small',
        species  = 'dog',
        canPet   = false,
        canTrick = false,
        icon     = 'dog',
    },
    {
        model    = 'dusa_sphynx',
        item     = 'murderface_sphynx',
        label    = 'Sphynx Cat',
        maxHealth = 350,
        price    = 9000,
        canHunt  = false,
        isK9     = false,
        animClass = 'cat',
        size     = 'small',
        species  = 'cat',
        canPet   = false,
        canTrick = false,
        icon     = 'cat',
    },

    -- ===== Addon Alternate Skins (dusa_addonpets streaming) =====
    {
        model    = 'A_C_Husky_2',
        item     = 'murderface_husky2',
        label    = 'Siberian Husky',
        maxHealth = 700,
        price    = 14000,
        canHunt  = true,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'A_C_Retriever_2',
        item     = 'murderface_retriever2',
        label    = 'Labrador Retriever',
        maxHealth = 600,
        price    = 8000,
        canHunt  = true,
        isK9     = false,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'A_C_shepherd_2',
        item     = 'murderface_shepherd2',
        label    = 'Belgian Malinois',
        maxHealth = 550,
        price    = 9000,
        canHunt  = true,
        isK9     = true,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'dog',
    },
    {
        model    = 'a_c_westy_2',
        item     = 'murderface_westy2',
        label    = 'West Highland Terrier',
        maxHealth = 350,
        price    = 3000,
        canHunt  = false,
        isK9     = false,
        animClass = 'small_dog',
        size     = 'small',
        species  = 'dog',
        canPet   = false,
        canTrick = false,
        icon     = 'dog',
    },

    -- ===== Police K9 (pdk9 streaming resource) =====
    {
        model    = 'pdk9',
        item     = 'murderface_pdk9',
        label    = 'Police K9',
        maxHealth = 800,
        price    = 0,
        canHunt  = true,
        isK9     = true,
        animClass = 'large_dog',
        size     = 'large',
        species  = 'dog',
        canPet   = true,
        canTrick = true,
        icon     = 'shield-halved',
        jobRestricted = { 'police', 'lspd', 'bcso', 'sasp', 'fib' },
    },

}

-- ========================================
--  Pre-indexed Lookups
--  Built at load time. Eliminates all O(n) loops.
--  Usage: Config.petsByItem['murderface_husky']
--         Config.petsByModel['A_C_Husky']
-- ========================================
Config.petsByItem = {}
Config.petsByModel = {}

for _, pet in ipairs(Config.pets) do
    Config.petsByItem[pet.item] = pet
    Config.petsByModel[pet.model] = pet
end

-- ========================================
--  Support Items
-- ========================================
Config.items = {
    food = {
        name = 'murderface_food',
        duration = 5,             -- seconds for feeding progress bar
    },
    collar = {
        name = 'murderface_collar',
        duration = 10,
    },
    nametag = {
        name = 'murderface_nametag',
        duration = 10,
    },
    firstaid = {
        name = 'murderface_firstaid',
        duration = 2,
        healPercent = 25,         -- % of maxHealth restored per use
        reviveBonus = 25,         -- HP above 100 after reviving dead pet
    },
    groomingkit = {
        name = 'murderface_groomingkit',
    },
    waterbottle = {
        name = 'murderface_waterbottle',
        duration = 2,
        maxCapacity = 6,          -- max water units in one bottle
        refillCost = 2,           -- water/water_bottle items consumed per fill
        refillAmount = 6,         -- water units added per fill (fills to full)
    },
    doghouse = {
        name = 'murderface_doghouse',
        duration = 3,             -- seconds for placement progress bar
    },
    leash = {
        name = 'murderface_leash',
    },
}

-- ========================================
--  Leash Settings
--  Prop-based visual leash between player hand and pet neck.
--  Requires dusa_addonpets (or equivalent) streaming resource for leash prop models.
-- ========================================
Config.leash = {
    enabled = true,
    length = 5.0,                  -- max leash length in meters (script-enforced)
    enforceDistance = true,         -- keep pet within leash range
    defaultModel = 'leash_model',  -- prop model name (leash_model / leash_model_2 / leash_model_3)
    models = {                     -- available leash variants (for shop / item selection)
        { item = 'murderface_leash',   prop = 'leash_model',   label = 'Black Leash',  price = 200 },
        { item = 'murderface_leash_2', prop = 'leash_model_2', label = 'Yellow Leash', price = 250 },
        { item = 'murderface_leash_3', prop = 'leash_model_3', label = 'Green Leash',  price = 250 },
    },
}

-- ========================================
--  Pet Shop Admin (in-game display placement)
--  /petshop command — place display dogs at pet shop locations
--  Players walk up and buy via ox_target
-- ========================================
Config.petShopAdmin = {
    enabled = true,
    acePermission = 'murderface-pets.petshop',  -- ace required for /petshop command
    spawnRadius = 40.0,                          -- proximity radius for display dog spawning
    displayAnim = 'sit',                         -- animation for display dogs (from Anims.classes)
}

-- ========================================
--  K9 Settings
--  K9-eligible models are determined by pet.isK9 = true above.
-- ========================================
Config.k9 = {
    jobs = { 'police' },
    illegalItems = {
        -- existing
        'weed_brick',
        'coke_small_brick',
        'coke_brick',
        -- cocaine
        'coke_box',
        'coke_leaf',
        'coke_raw',
        'coke_pure',
        'coke_figure',
        'coke_figureempty',
        -- meth
        'meth_bag',
        'meth_glass',
        'meth_sharp',
        -- weed
        'weed_package',
        'weed_bud',
        'weed_budclean',
        'weed_blunt',
        'weed_joint',
        -- heroin / opiates
        'heroin',
        'heroin_syringe',
        'poppyplant',
        -- crack
        'crack',
        -- pills / psychedelics
        'ecstasy1',
        'ecstasy2',
        'ecstasy3',
        'ecstasy4',
        'ecstasy5',
        'lsd1',
        'lsd2',
        'lsd3',
        'lsd4',
        'lsd5',
        'xanaxpack',
        'xanaxplate',
        'xanaxpill',
        'magicmushroom',
        'peyote',
        -- paraphernalia
        'meth_pipe',
        'crack_pipe',
        'syringe',
        'meth_syringe',
    },
}

-- ========================================
--  Pet Shop
-- ========================================
Config.petShop = {
    enabled = false,  -- disabled: Sandy Shores location handled by murderface-shops PetShop [2]
    ped = {
        model = 'a_m_m_farmer_01',
        coords = vector4(561.27, 2740.83, 42.8, 179.59),
        -- MLO coords (Patoche Pet Hospital): vector4(561.59, 2752.89, 42.16, 180.37)
    },
    blip = {
        sprite = 442,
        colour = 3,
        text = 'Pet Shop',
        shortRange = true,
    },
}

-- ========================================
--  Supplies Shop
-- ========================================
Config.suppliesShop = {
    enabled = false,  -- disabled: Sandy Shores location handled by murderface-shops PetShop [2]
    ped = {
        model = 'a_f_y_hipster_02',
        coords = vector4(563.42, 2741.02, 42.8, 181.57),
        -- MLO coords (Patoche Pet Hospital): vector4(563.59, 2751.89, 42.16, 180.37)
    },
    items = {
        { name = 'murderface_food',        label = 'Pet Food',              price = 100 },
        { name = 'murderface_firstaid',    label = 'Pet First Aid Kit',     price = 500 },
        { name = 'murderface_waterbottle', label = 'Portable Water Bottle', price = 300 },
        { name = 'murderface_collar',      label = 'Pet Collar',            price = 250 },
        { name = 'murderface_nametag',     label = 'Name Tag',              price = 150 },
{ name = 'murderface_groomingkit', label = 'Grooming Kit',          price = 750 },
        { name = 'murderface_doghouse',   label = 'Dog House',             price = 5000 },
        { name = 'murderface_leash',      label = 'Leash (Black)',         price = 200 },
        { name = 'murderface_leash_2',    label = 'Leash (Yellow)',        price = 250 },
        { name = 'murderface_leash_3',    label = 'Leash (Green)',         price = 250 },
    },
}

-- ========================================
--  Notification Helper (shared)
-- ========================================
-- Maps notification type names for rtx_notify compatibility.
-- ox_lib uses: 'inform','success','error','warning'
-- rtx_notify uses: 'info','success','error','warning'
local rtxTypeMap = { inform = 'info', success = 'success', error = 'error', warning = 'warning', info = 'info' }

--- Send a notification, routing through Config.notifySystem.
--- Client-side: fires directly. Server-side: fires to target player.
--- @param opts table { description, type, duration, title?, src? }
---   opts.src is required when called server-side (player source id)
function Config.notify(opts)
    local desc = opts.description or ''
    local nType = opts.type or 'info'
    local dur = opts.duration or 5000
    local title = opts.title or ''

    if Config.notifySystem == 'rtx_notify' then
        local mappedType = rtxTypeMap[nType] or 'info'
        if IsDuplicityVersion() then
            -- Server → Client
            if opts.src then
                TriggerClientEvent('rtx_notify:Notify', opts.src, title, desc, dur, mappedType)
            end
        else
            -- Client-side
            TriggerEvent('rtx_notify:Notify', title, desc, dur, mappedType)
        end
    else
        -- Fallback: ox_lib notify
        if IsDuplicityVersion() then
            if opts.src then
                TriggerClientEvent('ox_lib:notify', opts.src, { title = title ~= '' and title or nil, description = desc, type = nType, duration = dur })
            end
        else
            lib.notify({ title = title ~= '' and title or nil, description = desc, type = nType, duration = dur })
        end
    end
end
