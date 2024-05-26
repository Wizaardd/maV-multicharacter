MVS = exports["maV_core"]:getSharedObject()

local Start_Multicharacters = false
local cam = nil
local charPed = nil
local CharacterData = {}

local isLogin = false

local randommodels = {"mp_m_freemode_01","mp_f_freemode_01"}
local NUI = false

local SecurityData = nil

local number = 0

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(0)
    end
    
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(0)
    end
    StartMulticharacters()
end)

RegisterNetEvent('maV-multicharacters:RefreshUI', function()
    StartMulticharacters()
end)

StartMulticharacters = function()
	Start_Multicharacters = true
    if MVS.FrameworkName == "ESX" then
        SetNuiFocus(false, false)
        DoScreenFadeOut(10)
        Wait(1000)
        FreezeEntityPosition(PlayerPedId(), true)
        SetEntityCoords(PlayerPedId(), Config.Coords.CharacterSpawn.x, Config.Coords.CharacterSpawn.y, Config.Coords.CharacterSpawn.z)
        Wait(1500)
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        SetRainFxIntensity(-1.0)
        SetTimecycleModifier('default')
        DoScreenFadeOut(10)
        DoScreenFadeIn(1000)
        SetCam(true)
        SetupCharacters()
        StartWeatherLoop()
        
    elseif MVS.FrameworkName == "QB" then
        SetNuiFocus(false, false)
        DoScreenFadeOut(10)
        Wait(1000)
        FreezeEntityPosition(PlayerPedId(), true)
        SetEntityCoords(PlayerPedId(), Config.Coords.CharacterSpawn.x, Config.Coords.CharacterSpawn.y, Config.Coords.CharacterSpawn.z)
        Wait(1500)
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        SetRainFxIntensity(-1.0)
        SetTimecycleModifier('default')
        DoScreenFadeOut(10)
        DoScreenFadeIn(1000)
        SetCam(true)
        SetupCharacters()
        StartWeatherLoop()
    else
        MVS.Debug("["..GetCurrentResourceName().."] Framework = nil")
    end

    
	
end


SetUI = function(dd)
    NUI = dd
    SendNUIMessage({
        action = "setUI",
        ui = dd,
        locales = Locales[Config.Locale]
    })
    SetNuiFocus(dd, dd)
end

StartWeatherLoop = function()
    while NUI do
        NetworkOverrideClockTime(20, 0, 0)
        Wait(0)
    end

end


SetCam = function(dd) 
    if dd then
        Config.Hud:Disabled()
        if not DoesCamExist(cam) then
            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        end
        local model = joaat(randommodels[math.random(1, #randommodels)])
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        PedCreate(model, Config.Coords.CharacterCoords.x, Config.Coords.CharacterCoords.y, Config.Coords.CharacterCoords.z - 1, Config.Coords.CharacterCoords.h, {camcharacter = true})
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(charPed)
        local myHeading = GetEntityHeading(charPed)
        cameraOffset = GetOffsetFromEntityInWorldCoords(charPed, 0.0, 0.95, 0.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)
    
        SetCamCoord(cam, cameraOffset.x, cameraOffset.y, cameraOffset.z+0.60)
        PointCamAtCoord(cam, myCoords.x, myCoords.y, myCoords.z+0.60)
        SetCamFov(cam, 45.0)

        RequestAnimDict(Config.PedAnimation[1])
        while not HasAnimDictLoaded(Config.PedAnimation[1]) do
            Wait(1)
        end
        TaskPlayAnim(charPed, Config.PedAnimation[1], Config.PedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
            
        SetTimecycleModifier('MP_corona_heist_DOF')
        SetTimecycleModifierStrength(1.0)
        Wait(2000)
        DoScreenFadeIn(2000)
        
    else
        Config.Hud:Enabled()
        DoScreenFadeOut(500)
        Wait(1000)
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
        SetEntityVisible(PlayerPedId(), 1)
        
    end
end

local ccc = false

PedCreate = function(a,b,c,d,e,f)
    if not ccc then
        
        ccc = true
        if f ~= nil and f.camcharacter then
            DoScreenFadeOut(1)
        elseif f ~= nil and f.selectioncharacter then
            DoScreenFadeOut(500)
            Wait(1000)
        elseif f ~= nil and f.newcharacter then
            DoScreenFadeOut(500)
            Wait(1000)
        else
            DoScreenFadeOut(500)
            Wait(1000)
        end

        if f ~= nil and f.selectioncharacter then
            if Config.ClothingSystem == "esx" then
                if CharacterData[f.identifier].gender == "Male" then
                    models = GetHashKey("mp_m_freemode_01")
                else
                    models = GetHashKey("mp_f_freemode_01")
                end
                local loaded = loadModel(models)
                if loaded then
                    createped = CreatePed(2, models, b, c, d, e, false, true)
                    
                    ApplySkin(createped, json.decode(CharacterData[f.identifier].skin))
                    ClearPedTasks(createped)

                    FreezeEntityPosition(createped, false)
                    SetEntityInvincible(createped, true)
                    PlaceObjectOnGroundProperly(createped)
                    SetBlockingOfNonTemporaryEvents(createped, true)
                    RequestAnimDict(Config.PedAnimation[1])
                    while not HasAnimDictLoaded(Config.PedAnimation[1]) do
                        Wait(1)
                    end
                    TaskPlayAnim(createped, Config.PedAnimation[1], Config.PedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                    DeleteEntity(charPed)
                    DoScreenFadeIn(1000)
                    charPed = createped
                end
            else
                MVS.TriggerServerCallback("maV-multicharacter:getSkin", {f.identifier}, function(data)
                    if data ~= nil then
                        local model
                        if Config.ClothingSystem == "fivem-appearance" then
                            model = GetHashKey(data.model)
                            model = tonumber(model)
                        else
                            model = tonumber(data.model)
                        end
                        local loaded = loadModel(model)
                        data.skin = json.decode(data.skin)
                        if loaded then
                            createped = CreatePed(2, model, b, c, d, e, false, true)
                            Config.CharacterClothingLoad(createped, data)
                        end
                    else
                        print("Not Found error!")
                        return 
                    end
                end) 
                
                FreezeEntityPosition(createped, false)
                SetEntityInvincible(createped, true)
                PlaceObjectOnGroundProperly(createped)
                SetBlockingOfNonTemporaryEvents(createped, true)
                RequestAnimDict(Config.PedAnimation[1])
                while not HasAnimDictLoaded(Config.PedAnimation[1]) do
                    Wait(1)
                end
                TaskPlayAnim(createped, Config.PedAnimation[1], Config.PedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                DeleteEntity(charPed)
                DoScreenFadeIn(1000)
                charPed = createped
            end
            
        else


            createped = CreatePed(2, a, b, c, d, e, false, true)
            SetPedComponentVariation(createped, 0, 0, 0, 2)

            if charPed ~= nil then
                FreezeEntityPosition(createped, false)
                SetEntityInvincible(createped, true)
                PlaceObjectOnGroundProperly(createped)
                SetBlockingOfNonTemporaryEvents(createped, true)
                RequestAnimDict(Config.PedAnimation[1])
                while not HasAnimDictLoaded(Config.PedAnimation[1]) do
                    Wait(1)
                end
                TaskPlayAnim(createped, Config.PedAnimation[1], Config.PedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                    
                DeleteEntity(charPed)
                DoScreenFadeIn(1000)
                charPed = createped
                if f ~= nil and f.newcharacter then
                    SetEntityAlpha(charPed,0.9,false)
                end
                
            elseif f ~= nil and f.camcharacter then
                DoScreenFadeOut(1)
                charPed = createped
                SetEntityAlpha(charPed,1,false)
                
            else
                FreezeEntityPosition(createped, false)
                SetEntityInvincible(createped, true)
                PlaceObjectOnGroundProperly(createped)
                SetBlockingOfNonTemporaryEvents(createped, true)
                RequestAnimDict(Config.PedAnimation[1])
                while not HasAnimDictLoaded(Config.PedAnimation[1]) do
                    Wait(1)
                end
                TaskPlayAnim(createped, Config.PedAnimation[1], Config.PedAnimation[2], 8.0, 0.0, -1, 1, 0, 0, 0, 0)
                    
                DeleteEntity(charPed)
                DoScreenFadeIn(1000)
                charPed = createped
                if f ~= nil and f.newcharacter then
                    SetEntityAlpha(charPed,0.9,false)
                end
            end
        end

        
        ccc = false
    end

end


SetupCharacters = function()
    CharacterData = {}
    CharacterDataYes = false
    CreateCharacterYes = false
    CharacterDataPromise = promise.new()
    MVS.TriggerServerCallback('maV-multicharacters:CheckCharacters', {},  function(data)
        number = data.total
        
        if MVS.FrameworkName == "ESX" then
            if number > 0 then
            
                for k,v in pairs(data.result) do
                    CharacterData[v.identifier] = {}
                    accounts = json.decode(v.accounts)
                    local cash, bank = 0
                    number = data.total
                    if accounts.money ~= nil then
                        cash = accounts.money
                    end
                    if accounts.bank ~= nil then
                        bank = accounts.bank
                    end
                    if v.sex == "M" then
                        v.sex = "Male"
                    else
                        v.sex = "Female"
                    end
                    CharacterData[v.identifier] = {
                        name = v.firstname.." "..v.lastname,
                        identifier = v.identifier,
                        age = v.dateofbirth,
                        gender = v.sex,
                        level = v.level,
                        nation = v.nation,
                        xp = v.xp,
                        cash = cash,
                        bank = bank,
                        skin = v.skin,
                        online = 0
                    }
                    local hours = 0
                    if data.onlinetime[v.identifier] ~= nil then
                        minute = data.onlinetime[v.identifier].gametime
                        if minute >= 60 then
                            while minute >= 60 do
                                hours =  hours + 1
                                minute = minute - 60
                            end
                        end
    
                        if hours > 0 then
                            CharacterData[v.identifier].online = hours.." h "..minute.." min"
                        else
                            CharacterData[v.identifier].online = minute.." min"
                        end
                    else
                        CharacterData[v.identifier].online = "0 min"
                    end
                end
                CharacterDataYes = true
                CharacterDataPromise:resolve()
                
            else
                
    
                local model = joaat(randommodels[math.random(1, #randommodels)])
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(0)
                end
                PedCreate(model, Config.Coords.CharacterCoords.x, Config.Coords.CharacterCoords.y, Config.Coords.CharacterCoords.z - 1, Config.Coords.CharacterCoords.h, {newcharacter = true})
                SetEntityAlpha(charPed,0.9,false)
                CreateCharacterYes = true
                CharacterDataPromise:resolve()
            end

        elseif MVS.FrameworkName == "QB" then
            if number > 0 then
            
                for k,v in pairs(data.result) do
                    CharacterData[v.citizenid] = {}
                    accounts = json.decode(v.money)
                    charinfo = json.decode(v.charinfo)
                    local cash, bank = 0
                    number = data.total
                    if accounts.money ~= nil then
                        cash = accounts.cash
                    end
                    if accounts.bank ~= nil then
                        bank = accounts.bank
                    end
                    if charinfo.gender == 0 then
                        charinfo.gender = "Male"
                    else
                        charinfo.gender = "Female"
                    end
                    CharacterData[v.citizenid] = {
                        name = charinfo.firstname.." "..charinfo.lastname,
                        identifier = v.citizenid,
                        age = charinfo.birthdate,
                        gender = charinfo.gender,
                        level = v.level,
                        nation = charinfo.nationality,
                        xp = v.xp,
                        cash = cash,
                        bank = bank,
                        online = 0
                    }
                    local hours = 0
                    if data.onlinetime[v.citizenid] ~= nil then
                        minute = data.onlinetime[v.citizenid].gametime
                        if minute >= 60 then
                            while minute >= 60 do
                                hours =  hours + 1
                                minute = minute - 60
                            end
                        end
    
                        if hours > 0 then
                            CharacterData[v.citizenid].online = hours.." h "..minute.." min"
                        else
                            CharacterData[v.citizenid].online = minute.." min"
                        end
                    else
                        CharacterData[v.citizenid].online = "0 min"
                    end
                end
                CharacterDataYes = true
                CharacterDataPromise:resolve()
                
            else
                
    
                local model = joaat(randommodels[math.random(1, #randommodels)])
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Citizen.Wait(0)
                end
                PedCreate(model, Config.Coords.CharacterCoords.x, Config.Coords.CharacterCoords.y, Config.Coords.CharacterCoords.z - 1, Config.Coords.CharacterCoords.h, {newcharacter = true})
                SetEntityAlpha(charPed,0.9,false)
                CreateCharacterYes = true
                CharacterDataPromise:resolve()
            end

        end

        
    end)
    Citizen.Await(CharacterDataPromise)
    SetUI(true)
    if CharacterDataYes then
        SendNUIMessage({
            action = "setupCharacters",
            data = CharacterData
        })
    elseif CreateCharacterYes then
        SendNUIMessage({
            action = "createCharacters",
        })

    end

    
end



RegisterNUICallback('Select', function(data, cb)
    local model = joaat(randommodels[math.random(1, #randommodels)])
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    PedCreate(model, Config.Coords.CharacterCoords.x, Config.Coords.CharacterCoords.y, Config.Coords.CharacterCoords.z - 1, Config.Coords.CharacterCoords.h, {selectioncharacter = true, identifier = data.id})

    SecurityData = data.id
end)

RegisterNUICallback('PlayCharacter', function(data, cb) 
    SetUI(false)
    SetCam(false)
    
    DeleteEntity(charPed)
    charPed = nil
    TriggerServerEvent("maV-multicharacters:PlayCharacter", SecurityData)

    isLogin = true
end)

RegisterNUICallback('CreateCharacter', function(data, cb)
    if MVS.FrameworkName == "ESX" then
        MVS.TriggerServerCallback("maV-multicharacters:CharacterLimitCheck", {number}, function(daaaa)
            if daaaa then
                SetUI(false)
                SetCam(false)
                
                DeleteEntity(charPed)
                charPed = nil
                TriggerServerEvent('maV-multicharacters:CreateCharacter', data.data)
                isLogin = true
            else
                Config.Notification(TranslateCap('characterLimit'), 2)
            end
        
        end)

    elseif MVS.FrameworkName == "QB" then
        local cData = {}
        alldata = data.data
        MVS.TriggerServerCallback("maV-multicharacters:CharacterLimitCheck", {number}, function(daaaa)
            if daaaa then
                SetUI(false)
                SetCam(false)
                
                DeleteEntity(charPed)
                charPed = nil
                cData.birthdate = data.data.date
                cData.firstname = alldata.firstname
                cData.lastname = alldata.lastname
                cData.nationality = alldata.nation
                cData.birthdate = alldata.birthdate
                if alldata.gender == "Male" then
                    cData.gender = 0
                elseif alldata.gender == "Female" then
                    cData.gender = 1
                end
                TriggerServerEvent('maV-multicharacters:CreateCharacter', cData, number)
                isLogin = true
            else
                Config.Notification(TranslateCap('characterLimit'), 2)
            end
        
        end)

    end
    
    

end)

RegisterNUICallback('PedOrNewCharacter', function()
    local model = joaat(randommodels[math.random(1, #randommodels)])
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    PedCreate(model, Config.Coords.CharacterCoords.x, Config.Coords.CharacterCoords.y, Config.Coords.CharacterCoords.z - 1, Config.Coords.CharacterCoords.h, {newcharacter = true})
    DoScreenFadeIn(1000)
end)

RegisterNUICallback('PedDelete', function()
    DoScreenFadeOut(500)

    DeleteEntity(charPed)
    charPed = nil
    Wait(1000)
    DoScreenFadeIn(1200)

end)

RegisterNUICallback('DeleteCharacter', function(data)
    SetUI(false)
    TriggerServerEvent('maV-multicharacters:DeleteCharacter', data.id)
end)


RegisterNetEvent('maV-multicharacters:LeaveUI', function()
    SetUI(false)
    DeleteEntity(charPed)
    charPed = nil
    DoScreenFadeIn(1200)

end)

RegisterNetEvent('maV-multicharacters:LeaveUINoApartment', function()
    SetUI(false)
    DeleteEntity(charPed)
    charPed = nil
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    DoScreenFadeIn(1200)

end)



AddEventHandler('onResourceStop', function (resourceName)
    if resourceName == GetCurrentResourceName() then
        DeleteEntity(charPed)
        charPed = nil
    end
end)
      






function ApplySkin(playerPed, skin, clothes)
    if skin ~= nil then
        Character = {}

        for k,v in pairs(skin) do
            Character[k] = v
    
        end
    
    
        SetPedHeadBlendData			(playerPed, Character['face'], Character['face'], Character['face'], Character['skin'], Character['skin'], Character['skin'], 1.0, 1.0, 1.0, true)
    
        SetPedHairColor				(playerPed,			Character['hair_color_1'],		Character['hair_color_2'])					-- Hair Color
        SetPedHeadOverlay			(playerPed, 3,		Character['age_1'],				(Character['age_2'] / 10) + 0.0)			-- Age + opacity
        SetPedHeadOverlay			(playerPed, 0,		Character['blemishes_1'],		(Character['blemishes_2'] / 10) + 0.0)		-- Blemishes + opacity
        SetPedHeadOverlay			(playerPed, 1,		Character['beard_1'],			(Character['beard_2'] / 10) + 0.0)			-- Beard + opacity
        SetPedEyeColor				(playerPed,			Character['eye_color'], 0, 1)												-- Eyes color
        SetPedHeadOverlay			(playerPed, 2,		Character['eyebrows_1'],		(Character['eyebrows_2'] / 10) + 0.0)		-- Eyebrows + opacity
        SetPedHeadOverlay			(playerPed, 4,		Character['makeup_1'],			(Character['makeup_2'] / 10) + 0.0)			-- Makeup + opacity
        SetPedHeadOverlay			(playerPed, 8,		Character['lipstick_1'],		(Character['lipstick_2'] / 10) + 0.0)		-- Lipstick + opacity
        SetPedComponentVariation	(playerPed, 2,		Character['hair_1'],			Character['hair_2'], 2)						-- Hair
        SetPedHeadOverlayColor		(playerPed, 1, 1,	Character['beard_3'],			Character['beard_4'])						-- Beard Color
        SetPedHeadOverlayColor		(playerPed, 2, 1,	Character['eyebrows_3'],		Character['eyebrows_4'])					-- Eyebrows Color
        SetPedHeadOverlayColor		(playerPed, 4, 1,	Character['makeup_3'],			Character['makeup_4'])						-- Makeup Color
        SetPedHeadOverlayColor		(playerPed, 8, 1,	Character['lipstick_3'],		Character['lipstick_4'])					-- Lipstick Color
        SetPedHeadOverlay			(playerPed, 5,		Character['blush_1'],			(Character['blush_2'] / 10) + 0.0)			-- Blush + opacity
        SetPedHeadOverlayColor		(playerPed, 5, 2,	Character['blush_3'])														-- Blush Color
        SetPedHeadOverlay			(playerPed, 6,		Character['complexion_1'],		(Character['complexion_2'] / 10) + 0.0)		-- Complexion + opacity
        SetPedHeadOverlay			(playerPed, 7,		Character['sun_1'],				(Character['sun_2'] / 10) + 0.0)			-- Sun Damage + opacity
        SetPedHeadOverlay			(playerPed, 9,		Character['moles_1'],			(Character['moles_2'] / 10) + 0.0)			-- Moles/Freckles + opacity
        SetPedHeadOverlay			(playerPed, 10,		Character['chest_1'],			(Character['chest_2'] / 10) + 0.0)			-- Chest Hair + opacity
        SetPedHeadOverlayColor		(playerPed, 10, 1,	Character['chest_3'])														-- Torso Color
        SetPedHeadOverlay			(playerPed, 11,		Character['bodyb_1'],			(Character['bodyb_2'] / 10) + 0.0)			-- Body Blemishes + opacity
    
        if Character['ears_1'] == -1 then
            ClearPedProp(playerPed, 2)
        else
            SetPedPropIndex			(playerPed, 2,		Character['ears_1'],			Character['ears_2'], 2)						-- Ears Accessories
        end
    
        SetPedComponentVariation	(playerPed, 8,		Character['tshirt_1'],			Character['tshirt_2'], 2)					-- Tshirt
        SetPedComponentVariation	(playerPed, 11,		Character['torso_1'],			Character['torso_2'], 2)					-- torso parts
        SetPedComponentVariation	(playerPed, 3,		Character['arms'],				Character['arms_2'], 2)						-- Amrs
        SetPedComponentVariation	(playerPed, 10,		Character['decals_1'],			Character['decals_2'], 2)					-- decals
        SetPedComponentVariation	(playerPed, 4,		Character['pants_1'],			Character['pants_2'], 2)					-- pants
        SetPedComponentVariation	(playerPed, 6,		Character['shoes_1'],			Character['shoes_2'], 2)					-- shoes
        SetPedComponentVariation	(playerPed, 1,		Character['mask_1'],			Character['mask_2'], 2)						-- mask
        SetPedComponentVariation	(playerPed, 9,		Character['bproof_1'],			Character['bproof_2'], 2)					-- bulletproof
        SetPedComponentVariation	(playerPed, 7,		Character['chain_1'],			Character['chain_2'], 2)					-- chain
        SetPedComponentVariation	(playerPed, 5,		Character['bags_1'],			Character['bags_2'], 2)						-- Bag
    
        if Character['helmet_1'] == -1 then
            ClearPedProp(playerPed, 0)
        else
            SetPedPropIndex			(playerPed, 0,		Character['helmet_1'],			Character['helmet_2'], 2)					-- Helmet
        end
    
        if Character['glasses_1'] == -1 then
            ClearPedProp(playerPed, 1)
        else
            SetPedPropIndex			(playerPed, 1,		Character['glasses_1'],			Character['glasses_2'], 2)					-- Glasses
        end
    
        if Character['watches_1'] == -1 then
            ClearPedProp(playerPed, 6)
        else
            SetPedPropIndex			(playerPed, 6,		Character['watches_1'],			Character['watches_2'], 2)					-- Watches
        end
    
        if Character['bracelets_1'] == -1 then
            ClearPedProp(playerPed,	7)
        else
            SetPedPropIndex			(playerPed, 7,		Character['bracelets_1'],		Character['bracelets_2'], 2)				-- Bracelets
        end


    end
end

loadModel = function(model)
    RequestModel(model)
    for i = 1, 2500 do 
        if HasModelLoaded(model) then return true end
        RequestModel(model)
        Wait(1)
    end
    return false
end

RegisterNetEvent('maV-multicharacters:CreateOpenCharacterMenu', function(a)
    Config.CharacterCreationMenu()
end)

RegisterNetEvent('maV-multicharacters:OpenSpawnSelector', function(a)
    Config.SpawnSelector(a)
end)


if Config.Level.testcommand then
    RegisterCommand('uplevel', function(src, args)
        TriggerServerEvent('maV-multicharacters:Level:Up', args[1])
    end)

end

exports('maVLevelUp', function(xp)
    TriggerServerEvent('maV-multicharacters:Level:Up', xp)
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        if islogin then
            TriggerServerEvent('wiz:updateOnlineTime')
        end
    end
end)
