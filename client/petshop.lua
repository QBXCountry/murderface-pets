-- murderface-pets: Built-in pet shop system (client)
-- Admin places display dogs via /petshop command, players buy via ox_target.

local displayPeds = {}   -- { [displayId] = entity handle }
local displayData = {}   -- { [displayId] = row data from server }
local activePoints = {}  -- lib.points proximity triggers
local isPlacing = false
local previewGhost = nil -- ghost ped during placement mode

-- ============================
--     Raycast Helper
-- ============================

local function screenToWorld(maxDist)
    maxDist = maxDist or 50.0
    local camPos = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local radX = math.rad(camRot.x)
    local radZ = math.rad(camRot.z)
    local dir = vector3(
        -math.sin(radZ) * math.abs(math.cos(radX)),
         math.cos(radZ) * math.abs(math.cos(radX)),
         math.sin(radX)
    )
    local endPos = camPos + dir * maxDist
    local retval, hit, endCoords = GetShapeTestResult(
        StartShapeTestRay(camPos.x, camPos.y, camPos.z, endPos.x, endPos.y, endPos.z, 1 + 16 + 256, PlayerPedId(), 0)
    )
    if retval == 2 and hit then
        return true, endCoords
    end
    return false, endPos
end

-- ============================
--     Display Dog Spawning
-- ============================

local function spawnDisplayDog(data)
    local id = data.id
    if displayPeds[id] then return end

    local petCfg = Config.petsByItem[data.pet_item]
    if not petCfg then return end

    local modelHash = type(petCfg.model) == 'string' and GetHashKey(petCfg.model) or petCfg.model
    lib.requestModel(modelHash, 10000)
    if not HasModelLoaded(modelHash) then return end

    local ped = CreatePed(4, modelHash, data.x, data.y, data.z - 1.0, data.heading, false, true)
    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(modelHash)
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    -- Play sit animation if available
    local animClass = petCfg.animClass
    local displayAnim = Config.petShopAdmin.displayAnim or 'sit'
    if animClass and Anims.hasAction(animClass, displayAnim) then
        Anims.play(ped, animClass, displayAnim)
    end

    -- Apply variation if stored
    if data.variation and Variations then
        Variations.apply(ped, petCfg.model, data.variation)
    end

    displayPeds[id] = ped
    SetModelAsNoLongerNeeded(modelHash)

    -- ox_target: Buy interaction (everyone)
    local targetOptions = {
        {
            name = 'petshop_buy_' .. id,
            icon = 'fas fa-shopping-cart',
            label = string.format('Buy %s — $%s', data.label or petCfg.label, data.price),
            distance = 2.5,
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Buy ' .. (data.label or petCfg.label),
                    content = string.format('Purchase this %s for $%s?', data.label or petCfg.label, data.price),
                    centered = true,
                    cancel = true,
                })
                if confirm ~= 'confirm' then return end

                local success, msg = lib.callback.await('murderface-pets:petshop:buy', false, id)
                if success then
                    lib.notify({
                        title = 'Pet Shop',
                        description = 'You purchased a ' .. (msg or 'pet') .. '!',
                        type = 'success',
                        duration = 7000,
                    })
                else
                    lib.notify({
                        description = msg or 'Purchase failed',
                        type = 'error',
                        duration = 5000,
                    })
                end
            end,
        },
        {
            name = 'petshop_info_' .. id,
            icon = 'fas fa-info-circle',
            label = 'View Info',
            distance = 3.0,
            onSelect = function()
                lib.registerContext({
                    id = 'petshop_info_' .. id,
                    title = data.label or petCfg.label,
                    options = {
                        {
                            title = petCfg.label,
                            icon = petCfg.icon or 'paw',
                            iconColor = '#12b886',
                            description = string.format('%s — %s',
                                (petCfg.species or ''):gsub('^%l', string.upper),
                                petCfg.size or 'unknown'),
                            metadata = {
                                { label = 'Price', value = '$' .. (data.price or petCfg.price) },
                                { label = 'Max Health', value = tostring(petCfg.maxHealth) },
                                { label = 'Can Hunt', value = petCfg.canHunt and 'Yes' or 'No' },
                                { label = 'K9 Capable', value = petCfg.isK9 and 'Yes' or 'No' },
                                { label = 'Tricks', value = petCfg.canTrick and 'Yes' or 'No' },
                            },
                        },
                    },
                })
                lib.showContext('petshop_info_' .. id)
            end,
        },
    }

    -- Admin-only options
    local isAdmin = lib.callback.await(
        'murderface-pets:server:hasPetshopAce',
        false
    )
    
    if isAdmin then
        targetOptions[#targetOptions + 1] = {
            name = 'petshop_delete_' .. id,
            icon = 'fas fa-trash',
            label = 'Delete Display',
            distance = 3.0,
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Delete Display Dog',
                    content = 'Remove this display permanently?',
                    centered = true,
                    cancel = true,
                })
                if confirm ~= 'confirm' then return end
                lib.callback.await('murderface-pets:petshop:delete', false, id)
            end,
        }
    
        targetOptions[#targetOptions + 1] = {
            name = 'petshop_price_' .. id,
            icon = 'fas fa-dollar-sign',
            label = 'Change Price',
            distance = 3.0,
            onSelect = function()
                local input = lib.inputDialog('Change Price', {
                    { type = 'number', label = 'New Price ($)', required = true, min = 0 },
                })
                if not input then return end
                lib.callback.await('murderface-pets:petshop:updatePrice', false, id, input[1])
            end,
        }
    end

    exports.ox_target:addLocalEntity(ped, targetOptions)
end

local function despawnDisplayDog(id)
    local ped = displayPeds[id]
    if ped and DoesEntityExist(ped) then
        exports.ox_target:removeLocalEntity(ped)
        DeleteEntity(ped)
    end
    displayPeds[id] = nil
end

local function despawnAllDisplays()
    for id in pairs(displayPeds) do
        despawnDisplayDog(id)
    end
end

-- ============================
--     Proximity Spawning
-- ============================

local function setupProximityPoints()
    for _, point in ipairs(activePoints) do
        point:remove()
    end
    activePoints = {}

    local radius = Config.petShopAdmin.spawnRadius or 40.0

    for id, data in pairs(displayData) do
        local point = lib.points.new({
            coords = vec3(data.x, data.y, data.z),
            distance = radius,
            displayId = id,
            onEnter = function(self)
                local d = displayData[self.displayId]
                if d then spawnDisplayDog(d) end
            end,
            onExit = function(self)
                despawnDisplayDog(self.displayId)
            end,
        })
        activePoints[#activePoints + 1] = point
    end
end

-- ============================
--     Sync from Server
-- ============================

RegisterNetEvent('murderface-pets:petshop:sync', function(list)
    despawnAllDisplays()
    displayData = {}
    for _, data in ipairs(list) do
        displayData[data.id] = data
    end
    setupProximityPoints()
end)

CreateThread(function()
    if not Config.petShopAdmin or not Config.petShopAdmin.enabled then return end
    Wait(3000)
    TriggerServerEvent('murderface-pets:petshop:requestSync')
end)

-- ============================
--     Placement Mode
-- ============================

local function startPlacement(petCfg)
    if isPlacing then return end
    isPlacing = true

    local modelHash = type(petCfg.model) == 'string' and GetHashKey(petCfg.model) or petCfg.model
    lib.requestModel(modelHash, 10000)
    if not HasModelLoaded(modelHash) then
        lib.notify({ description = 'Failed to load model', type = 'error' })
        isPlacing = false
        return
    end

    local heading = GetEntityHeading(PlayerPedId())
    local hit, hitCoords = screenToWorld()
    local posX, posY, posZ = hitCoords.x, hitCoords.y, hitCoords.z

    -- Ghost preview (stored at file scope for cleanup)
    local ghost = CreatePed(4, modelHash, posX, posY, posZ - 1.0, heading, false, true)
    previewGhost = ghost
    SetEntityAsMissionEntity(ghost, true, true)
    SetEntityAlpha(ghost, 180, false)
    SetEntityCollision(ghost, false, false)
    FreezeEntityPosition(ghost, true)
    SetBlockingOfNonTemporaryEvents(ghost, true)
    SetEntityInvincible(ghost, true)

    -- Play sit animation on preview
    if petCfg.animClass and Anims.hasAction(petCfg.animClass, 'sit') then
        Anims.play(ghost, petCfg.animClass, 'sit')
    end

    SetModelAsNoLongerNeeded(modelHash)

    CreateThread(function()
        while isPlacing do
            Wait(0)

            -- Disable attacks
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            -- HUD
            Draw2DText('~b~PET SHOP PLACER~s~~n~~g~E / LClick~s~ Place  ~r~Bksp / RClick~s~ Cancel~n~~y~Scroll~s~ Rotate  ~y~F~s~ Face Me', 4, { 255, 255, 255 }, 0.35, 0.01, 0.35)

            -- Position from raycast
            local rayHit, rayCoords = screenToWorld()
            if rayHit then
                posX, posY, posZ = rayCoords.x, rayCoords.y, rayCoords.z
            end
            SetEntityCoordsNoOffset(ghost, posX, posY, posZ - 1.0, false, false, false)

            -- Rotate with scroll
            if IsControlPressed(0, 241) then -- scroll up
                heading = heading + 3.0
            end
            if IsControlPressed(0, 242) then -- scroll down
                heading = heading - 3.0
            end
            SetEntityHeading(ghost, heading)

            -- F = face player direction
            if IsControlJustPressed(0, 75) then
                heading = GetEntityHeading(PlayerPedId())
                SetEntityHeading(ghost, heading)
            end

            -- Confirm: E or Left Click
            if IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 24) then
                -- Save to DB
                local dbId = lib.callback.await('murderface-pets:petshop:place', false, {
                    petItem = petCfg.item,
                    price = petCfg.price,
                    x = posX,
                    y = posY,
                    z = posZ,
                    heading = heading,
                })

                if dbId then
                    lib.notify({
                        title = 'Pet Shop',
                        description = petCfg.label .. ' display placed!',
                        type = 'success',
                        duration = 5000,
                    })
                else
                    lib.notify({ description = 'Failed to save display', type = 'error' })
                end

                -- Clean up ghost
                if DoesEntityExist(ghost) then DeleteEntity(ghost) end
                previewGhost = nil
                isPlacing = false
                return
            end

            -- Cancel: Backspace or Right Click
            if IsControlJustPressed(0, 194) or IsDisabledControlJustPressed(0, 25) then
                if DoesEntityExist(ghost) then DeleteEntity(ghost) end
                previewGhost = nil
                isPlacing = false
                lib.notify({ description = 'Placement cancelled', type = 'info' })
                return
            end
        end
    end)
end

-- ============================
--     /petshop Command
-- ============================

RegisterCommand('petshop', function(_, args)
    if not Config.petShopAdmin or not Config.petShopAdmin.enabled then return end

    -- Sub-command: remove nearest display
    if args[1] == 'remove' then
        local playerPos = GetEntityCoords(PlayerPedId())
        local nearestId, nearestDist = nil, 999999
        for id, data in pairs(displayData) do
            local dist = #(playerPos - vec3(data.x, data.y, data.z))
            if dist < nearestDist then
                nearestId = id
                nearestDist = dist
            end
        end
        if nearestId and nearestDist < 10.0 then
            local confirm = lib.alertDialog({
                header = 'Remove Display',
                content = string.format('Remove %s display? (%.1fm away)', displayData[nearestId].label or 'pet', nearestDist),
                centered = true,
                cancel = true,
            })
            if confirm == 'confirm' then
                lib.callback.await('murderface-pets:petshop:delete', false, nearestId)
                lib.notify({ description = 'Display removed', type = 'success' })
            end
        else
            lib.notify({ description = 'No display dog nearby', type = 'error' })
        end
        return
    end

    -- Main: breed picker menu
    local options = {}
    for _, pet in ipairs(Config.pets) do
        -- Skip job-restricted pets in the picker (admin can still place them)
        options[#options + 1] = {
            title = pet.label,
            icon = pet.icon or 'paw',
            iconColor = '#12b886',
            description = string.format('$%s — %s %s', pet.price, pet.size, pet.species),
            onSelect = function()
                startPlacement(pet)
            end,
        }
    end

    lib.registerContext({
        id = 'petshop_breed_picker',
        title = 'Place Pet Display',
        options = options,
    })
    lib.showContext('petshop_breed_picker')
end, false)

-- Cleanup on logout
RegisterNetEvent('qbx_core:client:onLogout', function()
    despawnAllDisplays()
    -- Clean up placement ghost if active
    if isPlacing and previewGhost and DoesEntityExist(previewGhost) then
        DeleteEntity(previewGhost)
    end
    isPlacing = false
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    despawnAllDisplays()
    if previewGhost and DoesEntityExist(previewGhost) then
        DeleteEntity(previewGhost)
    end
end)
