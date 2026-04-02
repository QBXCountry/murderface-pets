-- murderface-pets: Chat command shortcuts
-- Quick /sit, /come, /stay, /heel, /speak, /lay, /paw commands
-- Runs the same logic as the context menu but via chat.

-- Helper: get current pet or notify
local function getActivePet()
    local petData = ActivePed:read()
    if not petData then
        lib.notify({ description = 'No active pet', type = 'error', duration = 3000 })
        return nil
    end
    if not DoesEntityExist(petData.entity) then
        lib.notify({ description = 'Pet entity not found', type = 'error', duration = 3000 })
        return nil
    end
    if IsEntityDead(petData.entity) then
        lib.notify({ description = 'Your pet is unconscious', type = 'error', duration = 3000 })
        return nil
    end
    return petData
end

local function petName(petData)
    return petData.item.metadata.name or 'Your pet'
end

-- /sit — pet sits for a few seconds then resumes following
RegisterCommand('sit', function()
    local pet = getActivePet()
    if not pet then return end
    if not pet.animClass or not Anims.hasAction(pet.animClass, 'sit') then
        lib.notify({ description = petName(pet) .. " doesn't know how to sit", type = 'error', duration = 3000 })
        return
    end
    doSomethingIfPedIsInsideVehicle(pet.entity)
    Anims.play(pet.entity, pet.animClass, 'sit')
    lib.notify({ description = petName(pet) .. ' sits down', type = 'success', duration = 3000 })
    CreateThread(function()
        Wait(4000)
        if DoesEntityExist(pet.entity) and not IsEntityDead(pet.entity) and not IsWaiting(pet.item.metadata.hash) then
            TaskFollowTargetedPlayer(pet.entity, PlayerPedId(), 3.0, true)
        end
    end)
end, false)

-- /come — pet stops waiting and follows you
RegisterCommand('come', function()
    local pet = getActivePet()
    if not pet then return end
    local hash = pet.item.metadata.hash
    doSomethingIfPedIsInsideVehicle(pet.entity)
    SetWaiting(hash, false)
    TaskFollowTargetedPlayer(pet.entity, PlayerPedId(), 3.0, false)
    lib.notify({ description = petName(pet) .. ' comes to your side', type = 'success', duration = 3000 })
end, false)

-- /stay — pet stays at current position (same as Wait menu action)
RegisterCommand('stay', function()
    local pet = getActivePet()
    if not pet then return end
    local hash = pet.item.metadata.hash
    doSomethingIfPedIsInsideVehicle(pet.entity)
    SetWaiting(hash, true)
    if pet.animClass and Anims.hasAction(pet.animClass, 'sit') then
        Anims.play(pet.entity, pet.animClass, 'sit')
    end
    lib.notify({ description = petName(pet) .. ' stays put', type = 'success', duration = 3000 })
end, false)

-- /heel — pet follows closely (same as /come but feels different in RP)
RegisterCommand('heel', function()
    local pet = getActivePet()
    if not pet then return end
    local hash = pet.item.metadata.hash
    doSomethingIfPedIsInsideVehicle(pet.entity)
    SetWaiting(hash, false)
    -- Tight follow offset
    TaskFollowToOffsetOfEntity(pet.entity, PlayerPedId(), -0.8, -1.0, 0.0, 3.5, -1, 1.0, true)
    lib.notify({ description = petName(pet) .. ' heels at your side', type = 'success', duration = 3000 })
end, false)

-- /speak — bark!
RegisterCommand('speak', function()
    local pet = getActivePet()
    if not pet then return end
    if not pet.animClass or not Anims.hasAction(pet.animClass, 'bark') then
        lib.notify({ description = petName(pet) .. " can't speak on command", type = 'error', duration = 3000 })
        return
    end
    doSomethingIfPedIsInsideVehicle(pet.entity)
    SetAnimalMood(pet.entity, 1)
    PlayAnimalVocalization(pet.entity, 3, 'bark')
    Anims.play(pet.entity, pet.animClass, 'bark')
    lib.notify({ description = petName(pet) .. ' barks!', type = 'success', duration = 3000 })
    CreateThread(function()
        Wait(3000)
        if DoesEntityExist(pet.entity) and not IsEntityDead(pet.entity) and not IsWaiting(pet.item.metadata.hash) then
            TaskFollowTargetedPlayer(pet.entity, PlayerPedId(), 3.0, true)
        end
    end)
end, false)

-- /lay — lay down
RegisterCommand('lay', function()
    local pet = getActivePet()
    if not pet then return end
    if not pet.animClass or not Anims.hasAction(pet.animClass, 'sleep') then
        lib.notify({ description = petName(pet) .. " doesn't know how to lay down", type = 'error', duration = 3000 })
        return
    end
    doSomethingIfPedIsInsideVehicle(pet.entity)
    Anims.play(pet.entity, pet.animClass, 'sleep')
    lib.notify({ description = petName(pet) .. ' lays down', type = 'success', duration = 3000 })
    CreateThread(function()
        Wait(5000)
        if DoesEntityExist(pet.entity) and not IsEntityDead(pet.entity) and not IsWaiting(pet.item.metadata.hash) then
            TaskFollowTargetedPlayer(pet.entity, PlayerPedId(), 3.0, true)
        end
    end)
end, false)

-- /paw — paw shake trick
RegisterCommand('paw', function()
    local pet = getActivePet()
    if not pet then return end
    if not pet.animClass then
        lib.notify({ description = petName(pet) .. " doesn't know tricks", type = 'error', duration = 3000 })
        return
    end
    -- Check trick level requirement
    local petLevel = pet.item.metadata.level or 0
    local reqLevel = Config.trickLevels and Config.trickLevels.paw or 0
    if petLevel < reqLevel then
        lib.notify({ description = ('Unlocks at level %d'):format(reqLevel), type = 'error', duration = 3000 })
        return
    end
    doSomethingIfPedIsInsideVehicle(pet.entity)
    makeEntityFaceEntity(pet.entity, PlayerPedId())
    Anims.playSub(pet.entity, pet.animClass, 'tricks', 'paw')
    lib.notify({ description = petName(pet) .. ' offers a paw!', type = 'success', duration = 3000 })
    TriggerServerEvent('murderface-pets:server:updatePetStats',
        pet.item.metadata.hash, { key = 'activity', action = 'trick' })
end, false)

-- /petname — quick display of current pet's name and level
RegisterCommand('petname', function()
    local pet = getActivePet()
    if not pet then return end
    local level = pet.item.metadata.level or 0
    local title = Config.getLevelTitle(level)
    lib.notify({
        description = ('%s — Level %d (%s)'):format(petName(pet), level, title),
        type = 'inform', duration = 5000
    })
end, false)
