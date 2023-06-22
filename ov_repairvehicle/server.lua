ESX = nil
_source = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('fixkit', function(source)
	_source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	TriggerClientEvent('ov_repairvehicle:useFixKit', _source)
end)

RegisterNetEvent("ov_repairvehicle:FinishedFixing")
AddEventHandler("ov_repairvehicle:FinishedFixing", function()	
	local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.removeInventoryItem("fixkit", "1")
end)

RegisterNetEvent("ov_repairvehicle:DeineMuddaChecksYourAss")
AddEventHandler("ov_repairvehicle:DeineMuddaChecksYourAss", function(item1, item2, item3, untersucht)	
    local xPlayer = ESX.GetPlayerFromId(_source)

    local need1 = false
    local need2 = false
    local need3 = false

    if not untersucht then
        xPlayer.showNotification("Du musst das Fahrzeug erst untersuchen!")
    else

        if not item1 and not item2 and not item3 then
            xPlayer.showNotification("Es gibt nichts zum reparieren!")
            return
        end

        if item1 and xPlayer.getInventoryItem('lack').count >= 5 then
            need1 = true
        elseif item1 and xPlayer.getInventoryItem('lack').count <= 4 then
            xPlayer.showNotification("Du hast nicht genug ~r~Lack!")
        end
    
        if item2 and xPlayer.getInventoryItem('reifen').count >= 4 then
            need2 = true
        elseif item2 and xPlayer.getInventoryItem('reifen').count <= 3 then
            xPlayer.showNotification("Du hast nicht genug ~r~Reifen!")
        end
    
        if item3 and xPlayer.getInventoryItem('motor').count >= 1 then
            need3 = true
        elseif item3 and xPlayer.getInventoryItem('motor').count <= 0 then
            xPlayer.showNotification("Du hast keinen ~r~Motor!")
        end

        if (item1 == need1 and item2 == need2 and item3 == need3) or (item2 == need2 and item3 == need3) or (item1 == need1 and item3 == need3) or (item1 == need1 and item2 == need2) then
            TriggerClientEvent("ov_repairvehicle:repairTheFuckingVehicle", _source)

            if item1 == need1 then
                xPlayer.removeInventoryItem("lack", 5)
            end

            if item2 == need2 then
                xPlayer.removeInventoryItem("reifen", 4)
            end

            if item3 == need3 then
                xPlayer.removeInventoryItem("motor", 1)
            end
        end
    end
end)