-- murderface-pets: Built-in pet shop system (server)
-- Admin places display dogs in-game, players buy via ox_target.
-- DB-persisted, works standalone without murderface-shops.

local displayList = {} -- { [id] = row data }

-- ============================
--     Database
-- ============================

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS murderface_petshop_displays (
            id INT AUTO_INCREMENT PRIMARY KEY,
            pet_item VARCHAR(50) NOT NULL,
            model VARCHAR(100) NOT NULL,
            price INT NOT NULL,
            x FLOAT NOT NULL,
            y FLOAT NOT NULL,
            z FLOAT NOT NULL,
            heading FLOAT NOT NULL DEFAULT 0,
            label VARCHAR(100) NOT NULL DEFAULT 'Pet'
        )
    ]])

    local rows = MySQL.query.await('SELECT * FROM murderface_petshop_displays')
    if rows then
        for _, row in ipairs(rows) do
            displayList[row.id] = row
        end
    end
    print(('[murderface-pets] ^2Pet shop: loaded %d display dogs^0'):format(#(rows or {})))
end)

-- ============================
--     Sync
-- ============================

local function getDisplays()
    local list = {}
    for _, data in pairs(displayList) do
        list[#list + 1] = data
    end
    return list
end

local function syncDisplays(target)
    TriggerClientEvent('murderface-pets:petshop:sync', target or -1, getDisplays())
end

RegisterNetEvent('murderface-pets:petshop:requestSync', function()
    syncDisplays(source)
end)

-- ============================
--     Admin: Place Display
-- ============================

lib.callback.register('murderface-pets:petshop:place', function(src, data)
    if not IsPlayerAceAllowed(src, Config.petShopAdmin.acePermission) then return false end
    if type(data) ~= 'table' then return false end

    local petCfg = Config.petsByItem[data.petItem]
    if not petCfg then return false end

    local ok, dbId = pcall(MySQL.insert.await,
        'INSERT INTO murderface_petshop_displays (pet_item, model, price, x, y, z, heading, label) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { data.petItem, petCfg.model, data.price or petCfg.price, data.x, data.y, data.z, data.heading or 0, petCfg.label }
    )

    if not ok or not dbId then return false end

    displayList[dbId] = {
        id = dbId,
        pet_item = data.petItem,
        model = petCfg.model,
        price = data.price or petCfg.price,
        x = data.x, y = data.y, z = data.z,
        heading = data.heading or 0,
        label = petCfg.label,
    }

    syncDisplays()
    return dbId
end)

-- ============================
--     Admin: Delete Display
-- ============================

lib.callback.register('murderface-pets:petshop:delete', function(src, displayId)
    if not IsPlayerAceAllowed(src, Config.petShopAdmin.acePermission) then return false end
    if not displayList[displayId] then return false end

    MySQL.query('DELETE FROM murderface_petshop_displays WHERE id = ?', { displayId })
    displayList[displayId] = nil
    syncDisplays()
    return true
end)

-- ============================
--     Admin: Update Price
-- ============================

lib.callback.register('murderface-pets:petshop:updatePrice', function(src, displayId, newPrice)
    if not IsPlayerAceAllowed(src, Config.petShopAdmin.acePermission) then return false end
    if not displayList[displayId] or type(newPrice) ~= 'number' or newPrice < 0 then return false end

    MySQL.query('UPDATE murderface_petshop_displays SET price = ? WHERE id = ?', { newPrice, displayId })
    displayList[displayId].price = newPrice
    syncDisplays()
    return true
end)

-- ============================
--     Player: Buy Pet
-- ============================

lib.callback.register('murderface-pets:petshop:buy', function(src, displayId)
    local display = displayList[displayId]
    if not display then return false, 'Display not found' end

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false, 'Player not found' end

    local petCfg = Config.petsByItem[display.pet_item]
    if not petCfg then return false, 'Invalid pet type' end

    -- Job restriction check (e.g. pdk9 is police-only)
    if petCfg.jobRestricted then
        local playerJob = player.PlayerData.job and player.PlayerData.job.name
        local allowed = false
        for _, jobName in ipairs(petCfg.jobRestricted) do
            if playerJob == jobName then allowed = true; break end
        end
        if not allowed then
            return false, 'This pet is restricted to specific jobs'
        end
    end

    -- Money check (try cash first, then bank)
    local price = display.price
    local cash = player.PlayerData.money.cash or 0
    local bank = player.PlayerData.money.bank or 0

    local moneyType
    if cash >= price then
        moneyType = 'cash'
    elseif bank >= price then
        moneyType = 'bank'
    else
        return false, string.format('Not enough money ($%s needed)', price)
    end

    -- Deduct money
    player.Functions.RemoveMoney(moneyType, price, 'pet-shop-purchase')

    -- Create pet item with fresh metadata
    local metadata = {
        hash           = generateHash(),
        name           = randomName(),
        gender         = math.random(1, 2) == 1,
        age            = 0,
        food           = 100,
        thirst         = 0,
        owner          = player.PlayerData.charinfo,
        level          = 0,
        XP             = 0,
        health         = petCfg.maxHealth,
        variation      = Variations.getRandom(petCfg.model),
        specialization = nil,
    }

    local success = exports.ox_inventory:AddItem(src, display.pet_item, 1, metadata)
    if not success then
        -- Refund
        player.Functions.AddMoney(moneyType, price, 'pet-shop-refund')
        return false, 'Inventory full'
    end

    return true, petCfg.label
end)
