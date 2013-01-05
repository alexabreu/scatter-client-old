local json = require("json")
local utilities = require("com.scatter.utilities")

local Game = {}

function Game.new(id, channel_id, total_player_count, current_player_count, game_time, status)
    
	local base = display.newGroup()
    
    base["id"] = id
    base["channel_id"] = channel_id
    base["total_player_count"] = total_player_count
    base["current_player_count"] = current_player_count
    base["game_time"] = game_time
    base["status"] = status
    base["is_player_in_game"] = true
    base["subscribed"] = false
    base["elapsed_time"] = 0
    base["locations"] = {}
    base["distance_travelled"] = 0
    base["players"] = {}
    base["vertices"] = {}
    base["broadcast_count"] = 0
    
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
    
    function base:updateDistanceTravelled(location)
    	utilities.printTable(location)
    	table.insert(base["locations"], location)
    	local location_count = table.getn( base["locations"] )
    	if  location_count > 1  then
    		local relative_distance = utilities.getDistanceBetween(base["locations"][location_count - 1], location)
    		base["distance_travelled"] = base["distance_travelled"] + relative_distance
    		print ("Relative distance: " .. relative_distance)
    		print ("Total distance: " .. base["distance_travelled"])
    	end
    end
    
    
    function base:didLose(user_id)
    	local did_lose = true
    	for i=1, #base["vertices"] do
    		if  user_id == base["vertices"][i] then
    			print("Good job amigo, you did not lose!!!!!!!")
    			did_lose = false
    		end
    	end
    	
    	return did_lose
    end
    
    function base:hasLoser()
    	local has_loser = false
    	
    	if #base["vertices"] == #base["players"] then
    		has_loser = true
    	end
    	
    	return has_loser
    	
    end
    
    
    function base:getAvatarID(user_id)
    	print("Getting avatar_id for user: " .. user_id)
    	local avatar_id = -1
    	
    	for i=1, #base["players"] do
    		if base["players"][i].id == user_id then
    			avatar_id = base["players"][i].avatar_id
    			print("Avatar id is: " .. avatar_id)
    		end
    	end    	
    	
    	return avatar_id
    end
    
    
    function base:getWinningAvatars()
    	winners = {}
    	for i=1, #base["vertices"] - 1 do
    		table.insert( winners, base:getAvatarID( base["vertices"][i] ) )
    	end
    	
    	return winners
    end
    
    
    function base:getLosingAvatars()
    	losers = {}
    	for i=1, #base["players"] do
    		local did_lose = true
    		for j=1, #base["vertices"] do
    			if base["vertices"][j] == base["players"][i].id then
    				did_lose = false
    			end
    		end
    		if did_lose then
    			table.insert( losers, base["players"][i].avatar_id )
    		end
    	end
    	
    	return losers
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