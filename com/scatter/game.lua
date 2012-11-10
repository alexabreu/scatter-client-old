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
    
        
    function base:leaveBeforeStart()
    	 base["is_player_in_game"] = false
    	_G.in_game = false
    	_G.current_game = {}
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