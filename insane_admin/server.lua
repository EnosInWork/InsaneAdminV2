ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('RubyMenu:getUsergroup', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local group = xPlayer.getGroup()
	print(GetPlayerName(source).." - "..group)
	cb(group)
end)

platenum = math.random(00001, 99998)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		local r = math.random(00001, 99998)
		platenum = r
	end
end)

RegisterServerEvent("vAdmin:GiveCash")
AddEventHandler("vAdmin:GiveCash", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addMoney((total))
	webh(p)
end)

RegisterServerEvent("vAdmin:GiveBanque")
AddEventHandler("vAdmin:GiveBanque", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addAccountMoney('bank', total)
	webh(p)
end)

RegisterServerEvent("vAdmin:GiveND")
AddEventHandler("vAdmin:GiveND", function(money)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local total = money
	
	xPlayer.addAccountMoney('black_money', total)
	webh(p)
end)



RegisterNetEvent("hAdmin:Message")
AddEventHandler("hAdmin:Message", function(id, type)
	TriggerClientEvent("hAdmin:envoyer", id, type)
end)

KickPerso = "ADMIN SYSTEM -"

RegisterServerEvent('vStaff:KickPerso')
AddEventHandler('vStaff:KickPerso', function(target, msg)
    name = GetPlayerName(source)
    DropPlayer(source,target, msg)
end)


function NoIdent(ident)
    if ident == 'steam:11' then
        return true
    else
        return false
    end
end

RegisterServerEvent("deleteVehAll")
AddEventHandler("deleteVehAll", function()
	TriggerClientEvent("RemoveAllVeh", -1)
end)

RegisterServerEvent("spawnVehAll")
AddEventHandler("spawnVehAll", function()
	TriggerClientEvent("SpawnAllVeh", -1)
end)


RegisterServerEvent("SavellPlayerAuto")
AddEventHandler("SavellPlayerAuto", function()
	ESX.SavePlayers(cb)
	print('^2Save des joueurs ^3Effectué')
end)

count = 0
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		count = count + 1

		if count >= 240 then
			ESX.SavePlayers(cb)
			print('^2Save des joueurs ^3Effectué')
			count = 0
		end
	end
end)

-----------------------------

-- Warn system
local warns = {}

RegisterNetEvent("STAFFMOD:RegisterWarn")
AddEventHandler("STAFFMOD:RegisterWarn", function(id, type)
	local steam = GetPlayerIdentifier(id, 1)
	local warnsGet = 0
	local found = false
	for k,v in pairs(warns) do
		if v.id == steam then
			found = true
			warnsGet = v.warns
			table.remove(warns, k)
			break
		end
	end
	if not found then
		table.insert(warns, {
			id = steam,
			warns = 1
		})
	else
		table.insert(warns, {
			id = steam,
			warns = warnsGet + 1
		})
	end
	print(warnsGet+1)
	if warnsGet+1 >= 3 then
		SessionBanPlayer(id, steam, source, type)
	else
		WarnsLog(id, source, type, false)
		TriggerClientEvent("STAFFMOD:RegisterWarn", id, type)
	end
end)

local SessionBanned = {}
local SessionBanMsg = "Vous avez été banni de la session de jeux pour une accumulation de warn. Merci de lire le règlement de nouveau et d'attendre la prochaine session de jeux pour jouer de nouveau."

function SessionBanPlayer(id, steam, source, type)
	table.insert(SessionBanned, steam)
	WarnsLog(id, source, type, true)
	DropPlayer(id, SessionBanMsg)
end

local webhook = "https://discord.com/api/webhooks/802623021110132756/5q0ElqXCR3awRsOWe_MaIE7RvqyCVKWAnwuRtHY66qWFalFc5gK6F6JkylgxPxPqTFwG"
function WarnsLog(IdWarned, IdSource, Reason, banned)
	if not banned then
		message = GetPlayerName(IdSource).." à warn "..GetPlayerName(IdWarned).." pour "..Reason
	else
		message = GetPlayerName(IdSource).." à warn "..GetPlayerName(IdWarned).." pour "..Reason.." et à été banni de la session pour accumulation de warn."
	end

	local discordInfo = {
			["color"] = "15158332",
			["type"] = "rich",
			["title"] = "**WARN**",
			["description"] = message,
			["footer"] = {
			["text"] = 'WARN SYSTEM' 
		}
	}
	PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({ username = 'RUBY WARN', embeds = { discordInfo } }), { ['Content-Type'] = 'application/json' })
end


---------------------------------------------------------


----- Reports


function reportadminok(player)
    local allowed = false
    for i,id in ipairs(reportadmin) do
        for x,pid in ipairs(GetPlayerIdentifiers(player)) do
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
    end
    return allowed
end

ESX.RegisterServerCallback('h4ci_report:affichereport', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local keys = {}

    MySQL.Async.fetchAll('SELECT * FROM report', {}, 
        function(result)
        for numreport = 1, #result, 1 do
            table.insert(keys, {
                id = result[numreport].id,
                type = result[numreport].type,
                sonid = result[numreport].sonid,
                reporteur = result[numreport].reporteur,
                nomreporter = result[numreport].nomreporter,
                raison = result[numreport].raison
            })
        end
        cb(keys)

    end)
end)

RegisterServerEvent('h4ci_report:ajoutreport')
AddEventHandler('h4ci_report:ajoutreport', function(typereport, sonid, reporteur, nomreporter, raison)
    MySQL.Async.execute('INSERT INTO report (type, sonid, reporteur, nomreporter, raison) VALUES (@type, @sonid, @reporteur, @nomreporter, @raison)', {
        ['@type'] = typereport,
        ['@sonid'] = sonid,
        ['@reporteur'] = reporteur,
        ['@nomreporter'] = nomreporter,
        ['@raison'] = raison
	})	
end)

RegisterServerEvent('h4ci_report:supprimereport')
AddEventHandler('h4ci_report:supprimereport', function(supprimer)
    MySQL.Async.execute('DELETE FROM report WHERE id = @id', {
            ['@id'] = supprimer
    })
end)


-------------------------------------------------------

RegisterCommand("newsreport", function(source, args, rawCommand)
    if source ~= 0 then
        local xPlayer = ESX.GetPlayerFromId(source)
            if args[1] then
                local message = string.sub(rawCommand, 3)
                local xAll = ESX.GetPlayers()
                for i=1, #xAll, 1 do
                    local xTarget = ESX.GetPlayerFromId(xAll[i])
                        TriggerClientEvent('chatMessage', xTarget.source, _U('newsreport', xPlayer.getName(), message))
                end
            else
                TriggerClientEvent('chatMessage', xPlayer.source, _U('invalid_input', 'AdminChat'))
            end
    end
end, false)

RegisterCommand("staffservice", function(source, args, rawCommand)
	if source ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(source)
		if havePermission(xPlayer) then
			if args[1] then
				local message = string.sub(rawCommand, 3)
				local xAll = ESX.GetPlayers()
				for i=1, #xAll, 1 do
					local xTarget = ESX.GetPlayerFromId(xAll[i])
					if havePermission(xTarget) then
						TriggerClientEvent('chatMessage', xTarget.source, _U('staffservice', xPlayer.getName(), xPlayer.getGroup(), message))
					end
				end
			else
				TriggerClientEvent('chatMessage', xPlayer.source, _U('invalid_inputt', 'AdminChat'))
			end
		end
	end
end, false)

msg = ""

RegisterCommand('alert', function(source, args, user)
	if (IsPlayerAceAllowed(source, "command")) then
			for i,v in pairs(args) do
				msg = msg .. " " .. v
			end
			TriggerClientEvent("alert", -1, msg)
			msg = ""
    end
end)

Locales['en'] = {
['newsreport']        = '\n^1Admin - Nouveau Report',
['invalid_input']        = '\n^1Admin - Nouveau Report',
['invalid_inputt']        = '\n^1Mode modération actif pour ^1[^4%s | Rang : %s^1]^0',
['staffservice']        = '\n^1Mode modération activé pour ^1[^4%s | Rang : %s^1]^0'
}


------------ functions and events ------------+

RegisterNetEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	deadPlayers[source] = data
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
	if deadPlayers[source] then
		deadPlayers[source] = nil
	end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	-- empty tables when player no longer online
	if onTimer[playerId] then
		onTimer[playerId] = nil
	end
    if savedCoords[playerId] then
    	savedCoords[playerId] = nil
    end
	if warnedPlayers[playerId] then
		warnedPlayers[playerId] = nil
	end
	if deadPlayers[playerId] then
		deadPlayers[playerId] = nil
	end
end)

function havePermission(xPlayer, exclude)	-- you can exclude rank(s) from having permission to specific commands 	[exclude only take tables]
	if exclude and type(exclude) ~= 'table' then exclude = nil; end	-- will prevent from errors if you pass wrong argument

	local playerGroup = xPlayer.getGroup()
	for k,v in pairs(Config.adminRanks) do
		if v == playerGroup then
			if not exclude then
				return true
			else
				for a,b in pairs(exclude) do
					if b == v then
						return false
					end
				end
				return true
			end
		end
	end
	return false
end

-----------------------


RegisterServerEvent('shop:vehicule')
AddEventHandler('shop:vehicule', function(vehicleProps, plate_625)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)', {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = plate_625,
        ['@vehicle'] = json.encode(vehicleProps)
    }, function(rowsChange)
    end)
end)

---------------------------

function webh(p)
    local xPlayer = ESX.GetPlayerFromId(source)
    local name = GetPlayerName(source)
	local ep = GetPlayerEP(source)
    local text = "Le staff : "..name.." c'est give de l'argent !"
    PerformHttpRequest(discord_webhook.url, 
    function(err, text, header) end, 
    'POST', 
    json.encode({username = serveur_name, content = text }), {['Content-Type'] = 'application/json'})
end
