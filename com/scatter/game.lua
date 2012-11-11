local json = require("json")
local utilities = require("com.scatter.utilities")

local Game = {}

function Game.new(id, channel_id, total_player_count, current_player_count, game_time)
    
	local base = display.newGroup()
    
    base["id"] = id
    base["channel_id"] = channel_id
    base["total_player_count"] = total_player_count
    base["current_player_count"] = current_player_count
    base["game_time"] = game_time
    base["status"] = "initializing"
    base["is_player_in_game"] = true
    base["subscribed"] = false
    
    
    function base.leaveGameEventHandler(event)
		native.setActivityIndicator(false)
		print(event.response)
		if ( event.isError ) then
	    	print( "!!! Error leaving quick game !!!" )
	    	print ("RESPONSE: " .. event.response )
	    else
	        if (event.status == 200) then
	        	print( "Successfully left quick game before start..." )
	        	print ("RESPONSE: " .. event.response )
	        	base["status"] = "left"
	        end        
	    end
	end
	
	function base.unsubscribeFromGameChannelEventHandler(event)
		native.setActivityIndicator(false)
		print(event.response)
		if ( event.isError ) then
	    	print( "!!! Error unsubscribing from game !!!" )
	    	print ("RESPONSE: " .. event.response )
	    else
	        if (event.status == 200) then
	        	print( "Successfully unsubscribed from game..." )
	        	print ("RESPONSE: " .. event.response )
	        	base["subscribed"] = false
	        end        
	    end
	end
	
    function base:leaveBeforeStart(unsubscribeFromGameChannelEventHandler)
    	_G.controller.leaveGame(base.leaveGameEventHandler)
    	_G.controller.unsubscribeFromGameChannel(_G.client_id, base["channel_id"], base.unsubscribeFromGameChannelEventHandler)
    	 base["is_player_in_game"] = false
    	_G.in_game = false

    end
    
    
    
    return base
end
 
return Game


--local Game = display.newGroup()
--local game_mt = { __index = Game }	-- metatable
--
--
--------------------------------- PRIVATE FUNCTIONS ------------------------------- 
--
--------------------------------- PRIVATE FUNCTIONS ------------------------------- 
--
--
--
--
--------------------------------- PUBLIC FUNCTIONS ------------------------------- 
--
--
--------------------------------- PUBLIC FUNCTIONS ------------------------------- 
--
--function Game.new(id, channel_id, total_player_count, current_player_count)	-- constructor
--	local g = {
--		id = id,
--		channel_id = channel_id,
--		total_player_count = total_player_count,
--		current_player_count = current_player_count,
--		status = "initializing",
--		is_player_in_game = true,
--	}
--	
--	return setmetatable( g, game_mt )
--end
--
--return Game