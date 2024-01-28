local Plugin = Shine.Plugin( ... )

Plugin.Version = "1.0"

Plugin.HasConfig = false
Plugin.DefaultState = true

function Plugin:Initialise()
    self.badgeData = {}

    Shared.SendHTTPRequest( "https://ns2panel.com/api/nsl-custom-badge-holders", "GET", { }, function ( data )
        local parsedData, _, errStr = json.decode(data)
        if errStr then
            Print("Error in parsing ns2panel NSL badge data: " .. ToString(errStr))
        else
            Print("Data successfully fetched from ns2panel")
            self.badgeData = parsedData
        end
    end)

    return true
end

function Plugin:Cleanup()
    self.badgeData = nil

    self.BaseClass.Cleanup(self)
end

Shine.Hook.Add( "ClientConnect", "ApplyNSLBadges", function ( Client )
    Print("Client with ns2id %s connected", Client:GetUserId())

    for _,data in ipairs(Plugin.badgeData) do
        local players = data['players']
        local badge = data['id']
        local name = data['name']
        Print("Checking badge %s", badge)
        for _,playerId in ipairs(players) do
            Print("Checking playerId %s", playerId)
            if playerId == Client:GetUserId() then
                Print("Granting %s badge %s (%s)", Client:GetUserId(), badge, name)
                local setBadge = GiveBadge( playerId, badge, 5 )
                if not setBadge then
                    Print("Falied to grant badge")
                    return
                end

                local setBadgeName = SetFormatBadgeName( badge, name )
                if not setBadgeName then
                    Print("Failed to set badge name")
                    return
                end
                return
            end
        end
    end
end)

return Plugin
