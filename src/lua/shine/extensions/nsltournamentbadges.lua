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
    -- NSL April Fools (Only if NSL mod is running)
    if kNSLPluginBuild then
        local badge = "nsl-april-fools"
        local name = "NSL Fellow"

        local setBadge = GiveBadge(Client:GetUserId(), badge, 6)
        if not setBadge then
            return
        end

        local setBadgeName = SetFormalBadgeName(badge, name)
        if not setBadgeName then
            return
        end
    end

    for _,data in ipairs(Plugin.badgeData) do
        local players = data['players']
        local badge = data['id']
        local name = data['name']
        for _,playerId in ipairs(players) do
            if playerId == Client:GetUserId() then
                local setBadge = GiveBadge( playerId, badge, 5 )
                if not setBadge then
                    return
                end

                local setBadgeName = SetFormalBadgeName( badge, name )
                if not setBadgeName then
                    return
                end
                return
            end
        end
    end
end)

return Plugin
