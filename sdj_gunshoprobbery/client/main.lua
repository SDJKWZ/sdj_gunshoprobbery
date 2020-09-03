local holdingUp = false
local store = ""
local blipRobbery = nil
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function drawTxt(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0,255)
	SetTextDropShadow()
	if outline then SetTextOutline() end

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('esx_customrob:currentlyRobbing')
AddEventHandler('esx_customrob:currentlyRobbing', function(currentStore)
	holdingUp, store = true, currentStore
end)

RegisterNetEvent('esx_customrob:killBlip')
AddEventHandler('esx_customrob:killBlip', function()
	RemoveBlip(blipRobbery)
end)

RegisterNetEvent('esx_customrob:setBlip')
AddEventHandler('esx_customrob:setBlip', function(position)
	blipRobbery = AddBlipForCoord(position.x, position.y, position.z)

	SetBlipSprite(blipRobbery, 161)
	SetBlipScale(blipRobbery, 2.0)
	SetBlipColour(blipRobbery, 3)

	PulseBlip(blipRobbery)
end)

RegisterNetEvent('esx_customrob:tooFar')
AddEventHandler('esx_customrob:tooFar', function()
	holdingUp, store = false, ''
	exports['esx_mythic_notify']:DoCustomHudText('inform', _U('robbery_cancelled'))
end)

RegisterNetEvent('esx_customrob:robberyComplete')
AddEventHandler('esx_customrob:robberyComplete', function(award)
	holdingUp, store = false, ''
	exports['esx_mythic_notify']:DoHudText('success', 'Robbery complete')
end)

Citizen.CreateThread(function()
	CreateObject(-1203351544, 598.28, -3139.25, 5.07, true, true, true)
end)

RegisterNetEvent('esx_customrob:startTimer')
AddEventHandler('esx_customrob:startTimer', function()
	local merryped2 = GetHashKey('s_m_y_marine_03')
	local gun = GetHashKey('WEAPON_COMBATPDW')
	local timer = Stores[store].secondsRemaining

	Citizen.CreateThread(function()
		while timer > 0 and holdingUp do
			Citizen.Wait(1000)

			if timer > 0 then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		AddRelationshipGroup('gunshop')
	end)

	Citizen.CreateThread(function()
		while holdingUp do
			Citizen.Wait(0)
			drawTxt(0.66, 1.44, 1.0, 1.0, 0.4, _U('robbery_timer', timer), 255, 255, 255, 255)
		end
	end)
end)

Citizen.CreateThread(function()
	for k,v in pairs(Stores) do
		local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
		SetBlipSprite(blip, 110)
		SetBlipScale(blip, 0.6)
		SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 1)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Gun Shop Robbery')
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPos = GetEntityCoords(PlayerPedId(), true)

		for k,v in pairs(Stores) do
			local storePos = v.position
			local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z)

			if distance < Config.Marker.DrawDistance then
				if not holdingUp then
					DrawMarker(Config.Marker.Type, storePos.x, storePos.y, storePos.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, false, false, false, false)

					if distance < 0.5 then
						ESX.ShowHelpNotification(_U('press_to_rob', v.nameOfStore))

						if IsControlJustReleased(0, 38) then
							TriggerServerEvent('esx_customrob:robberyStarted', k)
						end
					end
				end
			end
		end

		if holdingUp then
			local storePos = Stores[store].position
			if Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z) > Config.MaxDistance then
				TriggerServerEvent('esx_customrob:tooFar', store)
			end
		end
	end
end)
