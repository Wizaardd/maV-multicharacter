MVS = exports["maV_core"]:getSharedObject()



local loadFile = LoadResourceFile(GetCurrentResourceName(), "./json/data.json") -- you only have to do this once in your code, i just put it in since it wont get confusing.
local datajson = {}
datajson = json.decode(loadFile)

RegisterNetEvent('maV-multicharacters:CreateCharacter', function(dd, cc)
    local src = source
    if MVS.FrameworkName == "ESX" then
        local createidentifier = CreateCharId(src)
        newData = {
            firstname = dd.firstname,
            lastname = dd.lastname,
            sex = dd.gender,
            birthdate = dd.birthdate,
            identifier = createidentifier,
            nation = dd.nation
        }
        if MVS.Login(src, false, newData) then
            MVS.Log("["..GetCurrentResourceName().."] The character has been successfully created. ID: "..src..", Identifier: "..createidentifier..", Firstname: "..dd.firstname..", Lastname: "..dd.lastname.."")
            TriggerClientEvent('maV-multicharacters:CreateOpenCharacterMenu', src)
            TriggerClientEvent('maV-multicharacters:LeaveUI', src)
        else
            TriggerClientEvent('maV-multicharacters:RefreshUI', src)
        end
    elseif MVS.FrameworkName == "QB" then
        newData = {}
        newData.cid = cc
        newData.charinfo = dd
        if MVS.Login(src, false, newData) then
            if Config.StartingApartment then
                MVS.Log("["..GetCurrentResourceName().."] The character has been successfully created. ID: "..src..", Firstname: "..dd.firstname..", Lastname: "..dd.lastname.."")
                TriggerClientEvent('maV-multicharacters:CreateOpenCharacterMenu', src)
                TriggerClientEvent('maV-multicharacters:LeaveUI', src)
                TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
                loadHouseData()
                GiveStarterItems(src)
            else
                MVS.Log("["..GetCurrentResourceName().."] The character has been successfully created. ID: "..src..", Firstname: "..dd.firstname..", Lastname: "..dd.lastname.."")
                TriggerClientEvent('maV-multicharacters:CreateOpenCharacterMenu', src)
                TriggerClientEvent('maV-multicharacters:LeaveUINoApartment', src)
                loadHouseData()
                GiveStarterItems(src)
            end
           
            
        else
            TriggerClientEvent('maV-multicharacters:RefreshUI', src)
        end
    end
    
end)


GiveStarterItems = function(source)
    local src = source
    local Player = MVS.GetPlayer(src)

    for _, v in pairs(Config.GiveStarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.addItem(v.item, v.amount, false, info)
    end
end









MVS.RegisterServerCallback('maV-multicharacters:CheckCharacters', function(src, data, cb)
    result = MVS.GetAllCharacters(SearchIdentifier(src))
    post = {
        result = result,
        onlinetime = datajson,
        total = #result
    }
    cb(post)
end)


RegisterNetEvent('maV-multicharacters:PlayCharacter', function(id)
    local src = source
    if MVS.FrameworkName == "ESX" then
        if MVS.Login(src, id) then
            TriggerClientEvent('maV-multicharacters:LeaveUI', src)
            TriggerClientEvent('maV-multicharacters:OpenSpawnSelector', src)
        end
    elseif MVS.FrameworkName == "QB" then
        if MVS.Login(src, id) then
            TriggerClientEvent('maV-multicharacters:LeaveUI', src)
            TriggerClientEvent('maV-multicharacters:OpenSpawnSelector', src, id)
        end
    end

end)

RegisterNetEvent('maV-multicharacters:DeleteCharacter', function(id)
    local src = source
    MVS.MySQL.Sync.Execute("DELETE FROM `users` WHERE `identifier` = '"..id.."'") 
    TriggerClientEvent('maV-multicharacters:RefreshUI', src)
end)


MVS.RegisterServerCallback('maV-multicharacters:CharacterLimitCheck', function(source, data, cb)
    limit = 0
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if Config.CharacterPlayerLimit[v] ~= nil then
            if Config.CharacterPlayerLimit[v] > data[1] then
                return cb(true)
            end
        end
    end
    if Config.CharacterLimit > data[1] then
        return cb(true)
    end
    return cb(false)
end)



SearchIdentifier = function(source)
    ident = nil

    if Config.Identifier == "steam" then
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                ident = string.sub(v, 7)
            end
        end
        
    elseif Config.Identifier == "license" then
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                ident = string.sub(v, 9)
            end
        end
    elseif Config.Identifier == "discord" then
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("discord:")) == "discord:" then
                ident = string.sub(v, 9)
            end
        end
    end

    return ident
end


CreateCharId = function(source)
    local firstestid
    local lasttestid
    local id
    if Config.Identifier == "steam" then
        
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                id = v
            end
        end
        firstestid = id
        lasttestid = string.sub(id, 7)
    elseif Config.Identifier == "license" then
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("license:")) == "license:" then
                id = v
            end
        end
        firstestid = id
        lasttestid = string.sub(id, 9)
    elseif Config.Identifier == "discord" then
        for k,v in pairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("discord:")) == "discord:" then
                id = v
            end
        end
        firstestid = id
        lasttestid = string.sub(id, 9)
    end

    local UniqueFound = false
    local CitizenId = nil
    local firstest = false
    local number = 0

    while not UniqueFound do
        if not firstest then
            CitizenId = firstestid
            local result = MVS.MySQL.Sync.Execute("SELECT * FROM users WHERE  identifier LIKE '%"..CitizenId.."%'", {})
            if #result == 0 then
                UniqueFound = true
            else    
                firstest = true
            end
        else
            number = number + 1
            CitizenId = "Char" .. number .. ":" .. lasttestid
            local result = MVS.MySQL.Sync.Execute("SELECT * FROM users WHERE  identifier LIKE '%"..CitizenId.."%'", {})
            if #result == 0 then
                UniqueFound = true
            end
    
        end
    end
    local CitizenId = CitizenId
    return CitizenId
end


MVS.RegisterServerCallback("maV-multicharacter:getSkin", function(source, data, cb)
    local src = source
    local result
    local info
    

    if Config.ClothingSystem == "fivem-appearance" or Config.ClothingSystem == "qb" then
        result = MVS.MySQL.Sync.Execute("SELECT * FROM `playerskins` WHERE `citizenid` = '"..data[1].."' AND `active` = 1", {})

    end

    
    if result[1] ~= nil then
        cb(result[1])
    else
        cb(nil)
    end
end)


function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = MVS.MySQL.Sync.Execute("SELECT * FROM houselocations", {})
   
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = v.owned,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end
    TriggerClientEvent("qb-garages:client:houseGarageConfig", -1, HouseGarages)
    TriggerClientEvent("qb-houses:client:setHouseConfig", -1, Houses)
end


RegisterNetEvent('maV-multicharacters:Level:Up', function(aa)
    local src = source
    local xPlayer = MVS.GetPlayer(src)
    local identifier
    local result
    if MVS.FrameworkName == "ESX" then
        identifier = xPlayer.identifier
        result = MVS.MySQL.Sync.Execute("SELECT * FROM `users` WHERE `identifier` = '"..identifier.."' ", {})
        if result[1] ~= nil then
            dd = result[1]
            lvl = dd.level
            xp = dd.levelcount
            newxp = xp + tonumber(aa)
            if newxp >= Config.Level.uplevelxp then
                repeat
                    lvl = lvl + 1
                    newxp = newxp - Config.Level.uplevelxp
                until( newxp < Config.Level.uplevelxp )

                
            end

            MVS.MySQL.Sync.Execute("UPDATE `users` SET `level` = '"..lvl.."', levelcount = '"..newxp.."' WHERE `identifier` = '"..identifier.."'", {})
        else
            MVS.Log("["..GetCurrentResourceName().."] No data found. "..identifier)
        end
    elseif MVS.FrameworkName == "QB" then
        identifier = xPlayer.citizenid
        result = MVS.MySQL.Sync.Execute("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."' ", {})
        if result[1] ~= nil then
            dd = result[1]
            lvl = dd.level
            xp = dd.levelcount
            newxp = xp + tonumber(aa)
            if newxp >= Config.Level.uplevelxp then
                repeat
                    lvl = lvl + 1
                    newxp = newxp - Config.Level.uplevelxp
                until( newxp < Config.Level.uplevelxp )

                
            end

            MVS.MySQL.Sync.Execute("UPDATE `players` SET `level` = '"..lvl.."', levelcount = '"..newxp.."' WHERE `identifier` = '"..identifier.."'", {})
        else
            MVS.Log("["..GetCurrentResourceName().."] No data found. "..identifier)
        end
    end





end)

MVS.RegisterServerCallback('maV-multicharacters:Level:Get', function(src, data, cb)
    local xPlayer = MVS.GetPlayer(src)
    local identifier, result, lvl, xp = nil
    if MVS.FrameworkName == "ESX" then
        identifier = xPlayer.identifier
        result = MVS.MySQL.Sync.Execute("SELECT * FROM `users` WHERE `identifier` = '"..identifier.."' ", {})
        if result[1] ~= nil then
            dd = result[1]
            lvl = dd.level
            xp = dd.levelcount
        else
          
            MVS.Log("["..GetCurrentResourceName().."] No data found. "..identifier)
            return cb(nil)
        end
    elseif MVS.FrameworkName == "QB" then
        identifier = xPlayer.citizenid
        result = MVS.MySQL.Sync.Execute("SELECT * FROM `players` WHERE `citizenid` = '"..identifier.."' ", {})
        if result[1] ~= nil then
            dd = result[1]
            lvl = dd.level
            xp = dd.levelcount
        else
            MVS.Log("["..GetCurrentResourceName().."] No data found. "..identifier)
            return cb(nil)
        end
    end



    cb({lvl, xp})
end)


RegisterServerEvent("wiz:updateOnlineTime")
AddEventHandler("wiz:updateOnlineTime", function()
    local _source = source
    local xPlayer = MVS.GetPlayer(_source)
    if xPlayer ~= nil then
        print("SELAM")
        if MVS.FrameworkName == "ESX" then
            print(xPlayer.identifier)
            if datajson[xPlayer.identifier] ~= nil then
                datajson[xPlayer.identifier].gametime = datajson[xPlayer.identifier].gametime + 1
            else
                datajson[xPlayer.identifier] = {}
                datajson[xPlayer.identifier].gametime = 1
            end
        elseif MVS.FrameworkName == "QB" then
            if datajson[xPlayer.citizenid] ~= nil then
                datajson[xPlayer.citizenid].gametime = datajson[xPlayer.citizenid].gametime + 1
            else
                datajson[xPlayer.citizenid] = {}
                datajson[xPlayer.citizenid].gametime = 1
            end
        end

        SaveResourceFile(GetCurrentResourceName(), "./json/data.json", json.encode(datajson), -1)

    end     
    
end)
