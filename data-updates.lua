local mask_util = require("collision-mask-util")
local waterTileCollisionMask = data.raw["tile"]["water"].collision_mask

--function to check if a table contains a key without using a loop
function table.contains(table, key)
    return table[key] ~= nil
end
--function to check if a table contains a value
function table.containsValue(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

--function to get the index of a value in a table
function table.indexOf(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
    return nil
end

--generate table with all entity prototypes
local entityTable = {}
for type in pairs(defines.prototypes.entity) do
    for _, prototype in pairs(data.raw[type]) do
        entityTable[prototype.name] = prototype
    end
end

function entityCollidesWithWaterLayer(entity)
    --check if the entity has a collision_mask
    if entity == nil then
        return false
    end

    log("Checking entity: " .. entity.name)

    local mask = mask_util.get_mask(entity)

    if mask ~= nil then
        --check if the collision_mask contains the water layer
        --use serpent to print the table collision_mask
        if table.containsValue(mask, "water-tile") then
            return true
        end

    end

	return false
end

function createDummyEntity(originalEntity)
    local dummyEntity = table.deepcopy(originalEntity)
    --remove collision with water tile
    local originalMask = mask_util.get_mask(dummyEntity)
    if (not originalMask) then
        return nil
    end

    --remove water-tile from collision mask


    log("New mask: " .. serpent.line(newMask))
    dummyEntity.collision_mask = originalMask
    --remove all collsion mask items in water-tile-collsion-mask
    for _, item in pairs(waterTileCollisionMask) do
        local index = table.indexOf(dummyEntity.collision_mask, item)
        if index ~= nil then
            table.remove(dummyEntity.collision_mask, index)
        end
    end
    
        
    --change the name of the dummy prototype to "dummy-" .. name
    dummyEntity.name = "dummy-" .. dummyEntity.name

    

    --check if next-upgrade exists
    if dummyEntity.next_upgrade then
    --set the next_upgrade of the dummy prototype to "dummy-" .. next_upgrade
        dummyEntity.next_upgrade = "dummy-" .. dummyEntity.next_upgrade
    end

    --if the entity is minable, remove the mining result
    if dummyEntity.minable then
        dummyEntity.minable.result = nil
        dummyEntity.minable.results = nil
    end

    --return the dummy prototype
    return dummyEntity
end

function createDummyItem(originalItem)
    --check if the entity has a collision mask
            local dummyItem = table.deepcopy(originalItem)
            --change the name of the dummy prototype to "dummy-" .. name
            dummyItem.name = "dummy-" .. originalItem.name
            --chagne place_result to "dummy-" .. place_result
            dummyItem.place_result = "dummy-" .. originalItem.place_result

            return dummyItem
end


function GenerateDummyPrototpye() 
    for name, prototypeItem in pairs(data.raw["item"]) do
        if prototypeItem.place_result then
            if entityCollidesWithWaterLayer(entityTable[prototypeItem.place_result]) then
                log("Found entity that collides with water layer: " .. prototypeItem.place_result)
                local dummyItem = createDummyItem(prototypeItem)
                data:extend({dummyItem})
                local dummyEntity = createDummyEntity(entityTable[prototypeItem.place_result])
                data:extend({dummyEntity})
            end
        end
    end
end

GenerateDummyPrototpye()