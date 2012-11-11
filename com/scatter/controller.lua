local json = require("json")
local utilities = require("com.scatter.utilities")

local Controller = {}
local controller_mt = { __index = Controller }	-- metatable


------------------------------- PRIVATE FUNCTIONS ------------------------------- 

------------------------------- PRIVATE FUNCTIONS ------------------------------- 




------------------------------- PUBLIC FUNCTIONS ------------------------------- 


------------------------------- PUBLIC FUNCTIONS ------------------------------- 

--function Controller.new()	-- constructor
--
--	local c = {
--		client_id = nil,
--		session_id = nil
--	}
--
--	return setmetatable( c, controller_mt )
--end


function Controller.getSessionID(getSessionIDResponseHandler)
	print("Requesting sessionID...")
	
	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    params.headers = headers
    params.body = json.encode(data)
    
    print (_G.app_server .. "api/v1/debug")
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/debug", "GET", getSessionIDResponseHandler)
end


function Controller.handshakeWithMessageServer(handshakeWithMessageServerEventHandler)
	local params = {}
    local headers = {}
    local data = {}
    local message = {}
    
    --headers["Connection"] = "Keep-Alive"
    headers["Content-Type"] = "application/json"
    
    data["id"] = _G.message_id
    data["supportedConnectionTypes"] = {}
    data["supportedConnectionTypes"][1] = "callback-polling"
    data["version"] = "1.0"
    data["channel"] = "/meta/handshake"
    
    _G.message_id = _G.message_id + 1
    
    message[1] = data
    
    params.headers = headers
    params.body = json.encode(message)

    print("Shaking hands with message server...")
    print(_G.message_server)
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.message_server, "POST", handshakeWithMessageServerEventHandler, params)
    return 0
end


function Controller.subscribeToGameChannel(client_id, channel_id, subscribeToGameChannelEventHandler)
	local params = {}
    local headers = {}
    local data = {}
    local message = {}
    
    headers["Content-Type"] = "application/json"
    
    data["clientId"] = client_id
    data["channel"] = "/meta/subscribe"
    data["subscription"] = channel_id
    data["id"] = _G.message_id
    _G.message_id = _G.message_id + 1
    
    message[1] = data
        
    params.headers = headers
    params.body = json.encode(message)

    print("Subscribing to game channel...")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.message_server, "POST", subscribeToGameChannelEventHandler, params)
    return 0
end


function Controller.connectToGameChannel(connectToGameChannelEventHandler)
	local params = {}
    local headers = {}
    local data = {}
    local message = {}
    
    headers["Content-Type"] = "application/json"
    
    data["clientId"] = _G.client_id
    data["channel"] = "/meta/connect"
    data["connectionType"] = "cross-origin-long-polling"
    data["id"] = _G.message_id
    _G.message_id = _G.message_id + 1
    
    message[1] = data
    
    params.headers = headers
    params.body = json.encode(message)
    
    network.request( _G.message_server, "POST", connectToGameChannelEventHandler, params)
    return 0
end


function Controller.quickGame(location, quickGameEventHandler)
	print("Attempting to play a quick game...")

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    local game = {}
    game["lat"] = location.latitude
    game["lng"] = location.longitude
    game["accuracy"] = location.accuracy
    game["avatar_id"] = _G.game_settings.avatar_id
    data["game"] = game
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/quick.json")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/quick.json", "POST", quickGameEventHandler, params)
end


function Controller.createGame(game_name, player_count, location, createGameEventHandler)
	print("Attempting to create game with name: " .. game_name)

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    local game = {}
    game["name"] = game_name
    game["player_count"] = player_count
    data["game"] = game
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/create.json")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/create.json", "POST", createGameEventHandler, params)
end

function Controller.broadcastLocation(game_object, location, broadcastLocationEventHandler)
	print("Broadcasting location...")

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    local game = {}
    game["lat"] = location.latitude
    game["lng"] = location.longitude
    game["avatar_id"] = _G.game_settings.avatar_id
    data["game"] = game
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/" .. game_object.id .. "/check_in.json")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/" .. game_object.id .. "/check_in.json", "POST", broadcastLocationEventHandler, params)
end



function Controller.pingLocation(game_object, location, pingLocationEventHandler)
	print("Pinging location...")

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    local game = {}
    game["lat"] = location.latitude
    game["lng"] = location.longitude
    game["avatar_id"] = _G.game_settings.avatar_id
    data["game"] = game
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/" .. game_object.id .. "/ping.json")
    print(params.body)
    
    --native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/" .. game_object.id .. "/ping.json", "POST", pingLocationEventHandler, params)
end


function Controller.getActiveGames(getActiveGamesEventHandler)
	print("Attempting to get list of active games...")

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/active.json")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/active.json", "POST", getActiveGamesEventHandler, params)
end


function Controller.leaveGame(leaveGameEventHandler)
	print("Attempting to leave game before start: ")

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/leave.json")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/leave.json", "POST", leaveGameEventHandler, params)
end


function Controller.joinGame(game_id, joinGameEventHandler)
	print("Attempting to join game: " .. game_id)

	local params = {}
    local headers = {}
    local data = {}
    
    headers["Content-Type"] = "application/json; charset=utf-8"
    headers["Accept-Language"] = "en-US"
    headers["Accept"] = "application/json"
    
    data["auth"] = _G.game_settings.session_id
    --data["game[id]"] = game_id
    
    params.headers = headers
    params.body = json.encode(data)

    print(_G.app_server .. "api/v1/games/" .. game_id .. "/join.json")
    print(params.body)
    
    native.setActivityIndicator(true)
    network.request( _G.app_server .. "api/v1/games/" .. game_id .. "/join.json", "POST", joinGameEventHandler, params)
end


return Controller