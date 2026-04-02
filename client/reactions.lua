-- murderface-pets: Pet reactions to owner state
-- Pets respond naturally to what the player is doing:
--   Owner sits down -> pet lays at feet
--   Owner pulls out food -> pet whines/begs
--   Owner goes AFK -> pet sleeps next to them
--   Owner dies -> pet sits by body and whines (emotional RP moment)
--
-- Dependencies (defined in client/functions.lua + client/client.lua + shared/animations.lua):
--   ActivePed, Anims, IsGuarding, IsBusy, IsCarrying, IsWaiting, makeEntityFaceEntity

-- ============================
--        State Tracking
-- ============================
local ownerState = {
    sitting     = false,
    holdingFood = false,
    afk         = false,
    dead        = false,
}

local reactionCooldowns = {}
local afkTimer = 0
local lastPlayerPos = nil
local ownerDeathReacted = false

local REACTION_COOLDOWN = 15000

-- ============================
--        Helpers
-- ============================

local function canReact(reactionType)
    local now = GetGameTimer()
    local last = reactionCooldowns[reactionType] or 0
    if now - last < REACTION_COOLDOWN then return false end
    reactionCooldowns[reactionType] = now
    if Config.debug then print(('[murderface-pets] Owner reaction: %s'):format(reactionType)) end
    return true
end

local function forEachPet(fn)
    for hash, petData in pairs(ActivePed.pets) do
        if DoesEntityExist(petData.entity)
           and not IsEntityDead(petData.entity)
           and not IsGuarding(hash)
           and not IsBusy(hash)
           and not IsCarrying(hash)
           and not IsPedInAnyVehicle(petData.entity, false) then
            fn(hash, petData, petData.entity)
        end
    end
end

-- ============================
--   Reaction: Owner Sits Down
-- ============================

local function checkOwnerSitting()
    local plyPed = PlayerPedId()
    local isSitting = not IsPedSittingInAnyVehicle(plyPed) and IsPedUsingAnyScenario(plyPed)

    if not isSitting then
        if IsEntityPlayingAnim(plyPed, 'anim@amb@business@bgen@bgen_no_work@', 'sit_phone_phonecall_idle_a', 3)
           or IsEntityPlayingAnim(plyPed, 'timetable@ron@ig_5_p3', 'ig_5_p3_base', 3)
           or IsEntityPlayingAnim(plyPed, 'anim@heists@prison_sensormove', 'onesit_idle', 3) then
            isSitting = true
        end
    end

    if isSitting and not ownerState.sitting then
        ownerState.sitting = true
        if canReact('sit') then
            forEachPet(function(hash, petData, ped)
                local animClass = petData.animClass
                local plyPos = GetEntityCoords(plyPed)
                local petPos = GetEntityCoords(ped)
                if #(petPos - plyPos) > 2.0 then
                    TaskGoToEntity(ped, plyPed, -1, 1.2, 2.0, 0, 0)
                    CreateThread(function()
                        Wait(2500)
                        if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
                        ClearPedTasks(ped)
                        if animClass and Anims.hasAction(animClass, 'sleep') then
                            Anims.play(ped, animClass, 'sleep')
                        elseif animClass and Anims.hasAction(animClass, 'sit') then
                            Anims.play(ped, animClass, 'sit')
                        end
                    end)
                else
                    ClearPedTasks(ped)
                    if animClass and Anims.hasAction(animClass, 'sleep') then
                        Anims.play(ped, animClass, 'sleep')
                    elseif animClass and Anims.hasAction(animClass, 'sit') then
                        Anims.play(ped, animClass, 'sit')
                    end
                end
            end)
        end
    elseif not isSitting and ownerState.sitting then
        ownerState.sitting = false
        forEachPet(function(hash, petData, ped)
            if not IsWaiting(hash) then
                ClearPedTasks(ped)
                TaskFollowTargetedPlayer(ped, PlayerPedId(), 3.0, true)
            end
        end)
    end
end

-- ============================
--   Reaction: Owner Has Food
-- ============================

local function checkOwnerFood()
    local plyPed = PlayerPedId()
    local isEating = IsEntityPlayingAnim(plyPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger', 3)
                  or IsEntityPlayingAnim(plyPed, 'mp_player_inteat@pnq', 'loop', 3)
                  or IsEntityPlayingAnim(plyPed, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_c', 3)
                  or IsEntityPlayingAnim(plyPed, 'mp_player_intdrink', 'loop_bottle', 3)

    if isEating and not ownerState.holdingFood then
        ownerState.holdingFood = true
        if canReact('food') then
            forEachPet(function(hash, petData, ped)
                local animClass = petData.animClass
                makeEntityFaceEntity(ped, plyPed)

                local species = petData.petConfig and petData.petConfig.species or 'dog'
                if species == 'dog' then
                    PlayAnimalVocalization(ped, 3, 'whine')
                    -- Sit and beg — try tricks beg first, fall back to sit
                    local trickNames = Anims.getTrickNames(animClass)
                    local hasBeg = false
                    if trickNames then
                        for _, name in ipairs(trickNames) do
                            if name == 'beg' then hasBeg = true break end
                        end
                    end
                    if hasBeg then
                        Anims.playSub(ped, animClass, 'tricks', 'beg')
                    elseif animClass and Anims.hasAction(animClass, 'sit') then
                        Anims.play(ped, animClass, 'sit')
                    end
                    CreateThread(function()
                        Wait(2000)
                        if DoesEntityExist(ped) and not IsEntityDead(ped) then
                            PlayAnimalVocalization(ped, 3, 'whine')
                        end
                    end)
                end
            end)
        end
    elseif not isEating and ownerState.holdingFood then
        ownerState.holdingFood = false
    end
end

-- ============================
--   Reaction: Owner AFK
-- ============================

local AFK_THRESHOLD = 120 -- 2 minutes

local function checkOwnerAFK()
    local plyPed = PlayerPedId()
    local currentPos = GetEntityCoords(plyPed)

    if lastPlayerPos then
        local moved = #(currentPos - lastPlayerPos) > 0.5
        if moved then
            afkTimer = 0
            if ownerState.afk then
                ownerState.afk = false
                forEachPet(function(hash, petData, ped)
                    if not IsWaiting(hash) then
                        ClearPedTasks(ped)
                        if petData.animClass and Anims.hasAction(petData.animClass, 'bark') then
                            PlayAnimalVocalization(ped, 3, 'bark')
                        end
                        TaskFollowTargetedPlayer(ped, PlayerPedId(), 3.0, true)
                    end
                end)
            end
        else
            afkTimer = afkTimer + 1
        end
    end
    lastPlayerPos = currentPos

    if afkTimer >= AFK_THRESHOLD and not ownerState.afk then
        ownerState.afk = true
        if canReact('afk') then
            forEachPet(function(hash, petData, ped)
                local animClass = petData.animClass
                local petPos = GetEntityCoords(ped)
                local plyPos = GetEntityCoords(plyPed)
                if #(petPos - plyPos) > 2.0 then
                    TaskGoToEntity(ped, plyPed, -1, 1.2, 2.0, 0, 0)
                    CreateThread(function()
                        Wait(3000)
                        if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
                        ClearPedTasks(ped)
                        if animClass and Anims.hasAction(animClass, 'sleep') then
                            Anims.play(ped, animClass, 'sleep')
                        elseif animClass and Anims.hasAction(animClass, 'sit') then
                            Anims.play(ped, animClass, 'sit')
                        end
                    end)
                else
                    ClearPedTasks(ped)
                    if animClass and Anims.hasAction(animClass, 'sleep') then
                        Anims.play(ped, animClass, 'sleep')
                    elseif animClass and Anims.hasAction(animClass, 'sit') then
                        Anims.play(ped, animClass, 'sit')
                    end
                end
            end)
        end
    end
end

-- ============================
--   Reaction: Owner Dies
-- ============================

local function checkOwnerDeath()
    local plyPed = PlayerPedId()
    local isDead = IsEntityDead(plyPed) or IsPedDeadOrDying(plyPed, true)

    if isDead and not ownerState.dead then
        ownerState.dead = true
        ownerDeathReacted = false
    end

    if isDead and not ownerDeathReacted then
        ownerDeathReacted = true
        forEachPet(function(hash, petData, ped)
            local animClass = petData.animClass
            TaskGoToEntity(ped, plyPed, -1, 0.8, 2.0, 0, 0)

            CreateThread(function()
                Wait(2500)
                if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
                makeEntityFaceEntity(ped, plyPed)
                ClearPedTasks(ped)
                if animClass and Anims.hasAction(animClass, 'sit') then
                    Anims.play(ped, animClass, 'sit')
                end

                for i = 1, 3 do
                    Wait(3000 + math.random(1000))
                    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end
                    if not IsEntityDead(plyPed) then break end
                    PlayAnimalVocalization(ped, 3, 'whine')
                    SetAnimalMood(ped, 2)
                end
            end)
        end)
    elseif not isDead and ownerState.dead then
        ownerState.dead = false
        ownerDeathReacted = false
        forEachPet(function(hash, petData, ped)
            ClearPedTasks(ped)
            SetAnimalMood(ped, 1)
            PlayAnimalVocalization(ped, 3, 'bark')
            CreateThread(function()
                Wait(800)
                if DoesEntityExist(ped) and not IsEntityDead(ped) then
                    PlayAnimalVocalization(ped, 3, 'bark')
                end
            end)
            if not IsWaiting(hash) then
                TaskFollowTargetedPlayer(ped, PlayerPedId(), 3.0, true)
            end
        end)
    end
end

-- ============================
--   Main Reaction Thread
-- ============================

CreateThread(function()
    while true do
        Wait(1000)

        -- Early-out: skip all checks if no pets are active
        if not ActivePed.currentHash or not next(ActivePed.pets) then
            ownerState.sitting = false
            ownerState.holdingFood = false
            ownerState.afk = false
            ownerState.dead = false
            afkTimer = 0
            lastPlayerPos = nil
            ownerDeathReacted = false
            Wait(5000) -- sleep longer when no pets — saves cycles
            goto continue
        end

        if IsPedInAnyVehicle(PlayerPedId(), false) then
            goto continue
        end

        checkOwnerSitting()
        checkOwnerFood()
        checkOwnerAFK()
        checkOwnerDeath()

        ::continue::
    end
end)
