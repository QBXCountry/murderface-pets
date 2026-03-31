-- murderface-pets: Aggro/defense mode system (STANDALONE VERSION — NOT LOADED)
-- =====================================================================================
-- STATUS: DEAD CODE — This file is NOT listed in fxmanifest.lua and never loads.
-- The active aggro implementation lives in guard.lua (lines 219+), which contains
-- an enhanced copy with stuck-combat recovery (combatTarget/combatStart tracking)
-- and thread-stuck guard in StartAggro().
--
-- Kept for reference. To use this standalone version instead:
--   1. Remove the aggro section from guard.lua (lines 219–378)
--   2. Add 'client/aggro.lua' to fxmanifest.lua client_scripts
-- =====================================================================================
-- Pets auto-engage threats to the owner (defensive) and assist the owner in combat (offensive).

local aggroState = {}       -- { [petHash] = { active = bool, inCombat = bool } }
local aggroThreadRunning = false

-- ============================
--       Public Queries
-- ============================

function IsAggroEnabled(hash)
    return aggroState[hash] ~= nil and aggroState[hash].active == true
end

function IsInAggroCombat(hash)
    return aggroState[hash] ~= nil and aggroState[hash].inCombat == true
end

-- ============================
--     Monitoring Thread
-- ============================

local function activeAggroCount()
    local count = 0
    for _, state in pairs(aggroState) do
        if state.active then count = count + 1 end
    end
    return count
end

local function startAggroThread()
    if aggroThreadRunning then return end
    aggroThreadRunning = true

    CreateThread(function()
        local cfg = Config.aggro

        while activeAggroCount() > 0 do
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)

            -- Skip scanning if owner is dead or in a vehicle
            if not IsPedDeadOrDying(playerPed, false) and not IsPedInAnyVehicle(playerPed, false) then
                local pedPool = GetGamePool('CPed')

                for hash, state in pairs(aggroState) do
                    if state.active and not state.inCombat then
                        local petData = ActivePed:findByHash(hash)
                        if petData
                           and DoesEntityExist(petData.entity)
                           and not IsEntityDead(petData.entity)
                           and not IsPedInAnyVehicle(petData.entity, false)
                           and not IsGuarding(hash) then

                            local bestTarget = nil
                            local bestDist = math.huge

                            for _, ped in ipairs(pedPool) do
                                if ped ~= petData.entity
                                   and ped ~= playerPed
                                   and not IsEntityDead(ped)
                                   and not IsPedInAnyVehicle(ped, false) then

                                    if not cfg.attackPlayers and IsPedAPlayer(ped) then
                                        goto continue
                                    end

                                    local dist = #(playerPos - GetEntityCoords(ped))
                                    if dist <= cfg.detectionRange then
                                        local isDefensive = HasEntityBeenDamagedByEntity(playerPed, ped)
                                        local isOffensive = HasEntityBeenDamagedByEntity(ped, playerPed)

                                        if (isDefensive or isOffensive) and dist < bestDist then
                                            bestDist = dist
                                            bestTarget = ped
                                        end
                                    end

                                    ::continue::
                                end
                            end

                            if bestTarget then
                                state.inCombat = true

                                if cfg.notifyOwner then
                                    local petName = petData.item.metadata.name or 'Pet'
                                    lib.notify({
                                        title = petName,
                                        description = Lang:t('menu.action_menu.aggro_engaging'),
                                        type = 'warning',
                                        duration = 5000,
                                    })
                                end

                                TriggerServerEvent('murderface-pets:server:updatePetStats',
                                    hash, { key = 'activity', action = 'defending' })

                                local capturedHash = hash
                                local capturedTarget = bestTarget
                                CreateThread(function()
                                    AttackTargetedPed(petData.entity, capturedTarget)
                                    if aggroState[capturedHash] then
                                        aggroState[capturedHash].inCombat = false
                                    end
                                end)
                            end
                        end
                    end
                end

                ClearEntityLastDamageEntity(playerPed)
            end

            Wait(cfg.checkInterval)
        end

        aggroThreadRunning = false
    end)
end

-- ============================
--       Public Functions
-- ============================

function StartAggro(hash)
    aggroState[hash] = { active = true, inCombat = false }
    startAggroThread()
end

function StopAggro(hash)
    if not aggroState[hash] then return end
    aggroState[hash].active = false
    aggroState[hash] = nil
end

function StopAllAggro()
    for hash in pairs(aggroState) do
        StopAggro(hash)
    end
end
