-- murderface-pets: NUI bridge layer
-- Handles communication between Svelte UI and existing pet logic.
-- All game logic stays in menu.lua/petshop.lua/client.lua — this file only dispatches.
--
-- Dependencies: ActivePed, Config, menu functions (ExecuteAction, buildCompanionPayload),
--   petshop functions, ox_lib, ox_inventory

local nuiOpen = false

-- ============ OPEN / CLOSE ============

local function openNUI(screen, payload)
    if nuiOpen then return end
    nuiOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({
        type = screen,
        payload = payload,
    })
end

local function closeNUI()
    if not nuiOpen then return end
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'close' })
end

RegisterNUICallback('nui:close', function(_, cb)
    closeNUI()
    cb('ok')
end)

-- ============ COMPANION MENU ============

-- Opens the companion NUI (called from menu.lua keybind)
function OpenCompanionNUI()
    local payload = buildCompanionPayload()
    if not payload then return end
    openNUI('openCompanion', payload)
end

-- Live stat updates while companion menu is open
function UpdateCompanionStats(stats)
    if not nuiOpen then return end
    SendNUIMessage({
        type = 'updatePetStats',
        payload = stats,
    })
end

RegisterNUICallback('nui:companionAction', function(data, cb)
    local success = ExecuteAction(data.action)
    cb({ success = success ~= false, message = data.action })
end)

RegisterNUICallback('nui:companionTrick', function(data, cb)
    local success = ExecuteTrick(data.trick)
    cb({ success = success ~= false })
end)

RegisterNUICallback('nui:specialize', function(data, cb)
    local success = ExecuteSpecialize(data.specialization)
    cb({ success = success ~= false, message = data.specialization })
end)

RegisterNUICallback('nui:switchPet', function(data, cb)
    -- Switch active pet, then re-open companion with new data
    SwitchActivePet(data.hash)
    cb('ok')
    -- Re-send companion data after short delay for state to settle
    SetTimeout(200, function()
        if nuiOpen then
            local payload = buildCompanionPayload()
            if payload then
                SendNUIMessage({ type = 'openCompanion', payload = payload })
            end
        end
    end)
end)

RegisterNUICallback('nui:updateSetting', function(data, cb)
    if data.key == 'followDistance' then
        Config.balance.follow = Config.balance.follow or {}
        Config.balance.follow.distance = tonumber(data.value) or 2.5
    elseif data.key == 'ambientAI' then
        Config.balance.ambient.enabled = data.value == true
    elseif data.key == 'ownerReactions' then
        -- Toggle owner reactions (reactions.lua checks this)
        Config.ownerReactionsEnabled = data.value == true
    end
    cb('ok')
end)

RegisterNUICallback('nui:renamePet', function(data, cb)
    if not data.hash or not data.name then
        cb({ success = false })
        return
    end
    -- Use existing rename logic
    TriggerServerEvent('murderface-pets:server:renamePet', data.hash, data.name)
    -- Update local metadata
    local petData = ActivePed.pets[data.hash]
    if petData and petData.item and petData.item.metadata then
        petData.item.metadata.name = data.name
    end
    cb({ success = true })
end)

-- ============ PET SHOP ============

function OpenPetShopNUI(preselectedItem)
    local breeds = {}
    for _, petCfg in pairs(Config.pets) do
        breeds[#breeds + 1] = {
            item = petCfg.item,
            label = petCfg.label,
            model = petCfg.model,
            price = petCfg.price,
            species = petCfg.species or 'dog',
            size = petCfg.size or 'medium',
            maxHealth = petCfg.maxHealth or 500,
            canHunt = petCfg.canHunt or false,
            canTrick = petCfg.canTrick or false,
            isK9 = petCfg.isK9 or false,
            icon = petCfg.icon or 'paw',
            jobRestricted = petCfg.jobRestricted,
        }
    end

    -- Sort by price
    table.sort(breeds, function(a, b) return a.price < b.price end)

    -- Get player money
    local playerData = exports.qbx_core:GetPlayerData()
    local cash = playerData.money and playerData.money.cash or 0
    local bank = playerData.money and playerData.money.bank or 0

    -- Get variations for coat picker
    local variationData = {}
    for _, breed in ipairs(breeds) do
        local vars = Variations and Variations.getAll and Variations.getAll(breed.model)
        if vars then
            variationData[breed.item] = vars
        end
    end

    openNUI('openShop', {
        breeds = breeds,
        playerJob = playerData.job and playerData.job.name or '',
        playerMoney = { cash = cash, bank = bank },
        variations = variationData,
        preselectedItem = preselectedItem,
    })
end

RegisterNUICallback('nui:shopBuy', function(data, cb)
    closeNUI()
    -- Use existing server purchase callback
    local result = lib.callback.await('murderface-pets:petshop:buyDirect', false, {
        breedItem = data.breedItem,
        name = data.name,
        variation = data.variation,
        paymentMethod = data.paymentMethod,
    })
    cb(result or { success = false, message = 'Purchase failed' })
end)

-- ============ UTILITY ============

function IsNUIOpen()
    return nuiOpen
end

-- Force-close if pet dies or despawns while menu is open
CreateThread(function()
    while true do
        Wait(1000)
        if nuiOpen and ActivePed and not ActivePed.currentHash then
            closeNUI()
        end
    end
end)
