-- Auto Locals
local gesamt = 100
local reifen = 100
local motor_getriebe = 100

local _gesamt = false
local _reifen = false
local _motor_getriebe = false
local untersucht = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local Elements = {
    { label = "Fahrzeug untersuchen", name = "fahrzeug_untersuchen" },
    { label = "Fahrzeug reparieren", name = "fahrzeug_reparieren" }
}

RegisterNetEvent('ov_repairvehicle:useFixKit')
AddEventHandler('ov_repairvehicle:useFixKit', function()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "Reparatur_Menu", {
        title = "Reparatur",
        align    = 'top-left', 
        elements = Elements 
    }, function(data, menu) -- OnSelect Function
        if data.current.name == "fahrzeug_untersuchen" then
            kfz_untersuchen()
            menu.close()
        end

        if data.current.name == "fahrzeug_reparieren" then
            TriggerServerEvent("ov_repairvehicle:DeineMuddaChecksYourAss", _gesamt, _reifen, _motor_getriebe, untersucht)
            menu.close()
        end
    end, function(data, menu) -- Cancel Function
        menu.close()
    end)
end)

function kfz_untersuchen() 
    local veh = ESX.Game.GetVehicleInDirection()

    if veh == nil then
        ESX.ShowNotification("Es ist kein Fahrzeug in der Nähe.")
    elseif veh and not IsVehicleDriveable(veh, 1) then
        ESX.ShowNotification("Es gibt nichts zu untersuchen, Totalschaden")
    elseif veh then
        TriggerEvent("mythic_progbar:client:progress", {
            name = "unique_action_name",
            duration = 10000,
            label = "Untersuche das Fahrzeug...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer",
            }
        }, function(status)
            if not status then
                -- Do Something If Event Wasn't Cancelled
            end

            local vehicleHP = GetVehicleBodyHealth(veh)
            local engineHP = GetVehicleEngineHealth(veh)


            gesamt = vehicleHP / 10
            reifen = (vehicleHP * 2 + 1.5 * engineHP) / 20
            motor_getriebe = engineHP / 10

            if reifen >= 100 then
                reifen = 100.0
            end

            -- Welche Items brauche ich?

            if gesamt <= 10 then
                ESX.ShowNotification("Du benötigst ~g~5x Lack")
                _gesamt = true
            end

            if reifen <= 50 then
                ESX.ShowNotification("Du benötigst ~g~4x Reifen")
                _reifen = true
            end

            if motor_getriebe <= 50 then
                ESX.ShowNotification("Du benötigst ~g~1x Motor")
                _motor_getriebe = true
            end

            untersucht = true

            ESX.ShowNotification("» Fahrzeugzustand: " .. gesamt .. "%\n» Reifen: " .. reifen .."%\n» Motor/Getriebe: " .. motor_getriebe .. "%")
        end)
    end
end

RegisterNetEvent('ov_repairvehicle:repairTheFuckingVehicle')
AddEventHandler('ov_repairvehicle:repairTheFuckingVehicle', function()
    local veh = ESX.Game.GetVehicleInDirection()

    if veh == nil then
        ESX.ShowNotification("Es ist kein Fahrzeug in der Nähe.")
    else
        TriggerEvent("mythic_progbar:client:progress", {
            name = "unique_action_name",
            duration = 20000,
            label = "Repariere das Fahrzeug...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "mini@repair",
                anim = "fixing_a_player",
            }
        }, function(status)
            if not status then
                -- Do Something If Event Wasn't Cancelled
            end

            TriggerServerEvent("ov_repairvehicle:FinishedFixing")
            SetVehicleFixed(veh)
            SetVehicleDeformationFixed(veh)
            SetVehicleUndriveable(veh, false)

            untersucht = false
        end)
    end
end)