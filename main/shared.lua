Config = {}
Config.IsLogin = false

Config.Locale = "en" -- tr

--[[
    Config.CharacterLimit character creation limit that applies to everyone.
    Config.CharacterPlayerLimit To add character limit per person.
]]
Config.CharacterLimit = 3
Config.CharacterPlayerLimit = {
    ["steam:11111"] = 4
}

--[[
    Don't make it wrong or complete. Function required for the script to run properly.
]]
Config.Identifier = "license" -- discord or steam or license


-- QBCore Settings
Config.StartingApartment = false -- Enable/disable starting apartments (make sure to set default spawn coords)
Config.GiveStarterItems = {
    {item = "phone", count = 1},
    {item = "driver_license", count = 1},
    {item = "id_card", count = 1},
}
----------





Config.ClothingSystem = 'esx' -- "qb" or "fivem-appearance" or "raid" or "esx" or "other"
--Just use here for "qb-clothing", "raid", "fivem-appearance".
Config.Clothing_name = 'fivem-appearance' -- Your clothing resource name


Config.CharacterClothingLoad = function(charPed, data)
    if Config.ClothingSystem == "qb" then
        TriggerEvent(Config.Clothing_name .. ':client:loadPlayerClothing', data.skin, charPed)
    elseif Config.ClothingSystem == "raid" then
        exports[Config.Clothing_name]:SetPedMetadata(charPed, data)
    elseif Config.ClothingSystem == "fivem-appearance" then
        exports[Config.Clothing_name]:setPedAppearance(charPed, data.skin)
    else
        -- @other clothing function here
        
    end
end


Config.Notification = function(msg, typ)
   --[[
        msg: string
        typ: number

        1 = success
        2 = error
        3 = information
    ]]
    print(msg)
    TriggerEvent('wiz-notification', msg, typ)
end


--[[
    Export or trigger the scripts that you do not want to appear when the menu is open.
]]
Config.Hud = {
    Enabled = function()
        DisplayRadar(true)
    end,
    Disabled = function()
        DisplayRadar(false)
    end
}


--[[
    The spawn selector that will work when entering the character.
]]
Config.SpawnSelector = function(a)

    TriggerEvent('wiz-spawnselector:Open')  -- this the best

    TriggerEvent('apartments:client:setupSpawnUI', {citizenid = a})  -- this qb
end


--[[
    The skin menu that will come after creating the character.
]]
Config.CharacterCreationMenu = function()

    TriggerEvent('wiz-clothing:OpenCharacterCreator') -- this the best
    TriggerEvent('esx_skin:openSaveableMenu') -- this ESX

    TriggerEvent('qb-clothes:client:CreateFirstCharacter') -- this QB
end


Config.Level = {
    uplevelxp = 200,
    testcommand = true
} 













Config.DefaultSpawn = vector3(-1035.71, -2731.87, 12.86) -- Default spawn coords if you have start apartments disabled
Config.Coords = {
    CharacterSpawn = {
        x = -765.07, y = -1211.1, z = 51.1480
    },
    CharacterCoords = {
        x = -768.37, y = -1214.6, z = 51.1480, h = 226.388
    },
    CharacterLeaveScren = {
        x = -771.47, y = -1218.5, z = 51.1480
    }
}
Config.PedAnimation = {"missbigscore2aig_3", "wait_for_van_c"} -- animation of the player during character creation

