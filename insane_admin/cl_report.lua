ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

RegisterNetEvent('setreportadmin')
AddEventHandler('setreportadmin', function()
    reportadmingroup = true
end)    

Citizen.CreateThread(function()
    while true do
        Citizen.Wait( 2000 )

        if NetworkIsSessionStarted() then
            TriggerServerEvent("checkreportadmin")
        end
    end
end )

reportlistesql = {}

RMenu.Add('report', 'main', RageUI.CreateMenu("Report", " "))

Citizen.CreateThread(function()
	while true do
		
		RageUI.IsVisible(RMenu:Get('report', 'main'), true, true, true, function()
			
            RageUI.Button("Faire un appel staff", nil, {RightLabel = "📞"}, true, function(Hovered, Active, Selected)
                if (Selected) then
                for _, i in ipairs(GetActivePlayers()) do
                local reasonResults = Keyboardput("Raison de l'appel: ", "", 70)
                local playerName = GetPlayerName(PlayerId())
                local typereport = "Appel staff"
                local nameResults = "Staff"
                local sonid = GetPlayerServerId(i)
                TriggerEvent('chatMessage', "Appel Staff", {225, 29, 29}, " -  Votre appel admin a été envoyé pour \"" .. reasonResults.."\".")
                TriggerServerEvent('h4ci_report:ajoutreport', typereport, sonid, playerName, nameResults, reasonResults)
                notifreport()
                end
            end
		end)
			
			RageUI.Button("Faire un report", nil, {RightLabel = "📋"}, true, function(Hovered, Active, Selected)
				if (Selected) then
                    for _, i in ipairs(GetActivePlayers()) do
                    local nameResults = Keyboardput("Nom du Joueur:", "", 20)
                	local reasonResults = Keyboardput("Raison du Report: ", "", 70)
                    local playerName = GetPlayerName(PlayerId())
                    local typereport = "Report"
                    local sonid = GetPlayerServerId(i)
                    if nameResults == nil or nameResults == "" then
                    TriggerEvent('chatMessage', "Erreur Report", {255, 0, 0}, "Vous n'avez pas saisi de nom")
                    else
                    TriggerEvent('chatMessage', "Report Staff", {225, 29, 29}, " -  Votre report a été envoyé contre \"".. nameResults .. "\" pour \"" .. reasonResults.."\".")
                    TriggerServerEvent('h4ci_report:ajoutreport', typereport, sonid, playerName, nameResults, reasonResults)
                    notifreport()
                    end
                end
                end
            end)

            end, function()
			end)
            Citizen.Wait(0)
        end
    end)

RegisterCommand("report", function() 
    ESX.TriggerServerCallback('h4ci_report:affichereport', function(keys)
    reportlistesql = keys
    end)
  RageUI.Visible(RMenu:Get('report', 'main'), not RageUI.Visible(RMenu:Get('report', 'main')))
end)

function notifreport()
    ExecuteCommand("newsreport t")
end