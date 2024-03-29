-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local game = require( "com.scatter.game" )
local utilities = require( "com.scatter.utilities" )

local scene = storyboard.newScene()
local stage = display.getCurrentStage()


local new_game_button, join_game_button, quick_game_button

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------



local function floodGameWithDummies(index)
	print("Adding fake player to game with index: " .. index)
	local dummy = _G.dummies[index]
	local location = {}
	location["latitude"] = 0
	location["longitude"] = 0
	
	local dummy_quick_game_callback = function(event)
		native.setActivityIndicator(false)
		if (event.status == 200) then
			local data = {}
		    data = json.decode(event.response)
		    utilities.printTable(data)
			if (data ~= nil and data.game ~= nil) then	
		        if ( data.player_count < data.game.player_count ) then
		        	floodGameWithDummies(data.game.player_count - data.player_count)
		        end
		    else
		    	print("NO GO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		    	print(event.response)
			end
		end
	end
		
	_G.controller.quickGame(dummy["session_id"], location, dummy_quick_game_callback)
end

local function quickGameEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "!!! Error joining quick game !!!" )
    	print ("RESPONSE: " .. event.response )
    else
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response);
        	print (event.response)
        	if (data ~= nil and data.game ~= nil) then
        		print ("Successfully joined quick match....")
        		print(event.response)
        		local game = game.new(data.game.id, data.game.channel_id, data.game.player_count, data.player_count, _G.default_game_time, data.game.status)
        		_G.gMap:request( _G.app_server .. "games/" .. tostring(data.game.id) )
        		utilities.printTable(game)
        		_G.current_game = game
        		_G.in_game = true
        		_G.channel_id = data.game.channel_id
        		_G.controller.subscribeToGameChannel(_G.client_id, _G.channel_id, _G.subscribeToGameChannelEventHandler)
        		
				local options = {
				    effect = "slideLeft",
				    time = 300,
				    params = { game = game },
				}
				if (game.status == "initializing") then
					print("Not last player to join, going to waiting room...")			
					storyboard.gotoScene( "quick_game_wait", options )
				elseif ( game.status == "started" ) then
					print("Last player to join, going to game...")	
				    storyboard.gotoScene("play_game", options)
				end
				
				if (_G.debug_mode and data.player_count < data.game.player_count) then
        			floodGameWithDummies(data.game.player_count - data.player_count)
        		end
				
        	else
        		print ("!!! Failed to join quick game. Is player already in another game? !!!")
        		--Hack to force client to get a new session
        		_G.controller.getSessionID(_G.getSessionIDResponseHandler)
        	end
        end        
    end
end


local newGameButtonHandler = function (event )
    if event.phase == "release" then
        print( "Pressed create new game button..." )
        storyboard.gotoScene( "create_game", "fromLeft", 300 )
    end
end

local joinGameButtonHandler = function (event )
    if event.phase == "release" then
        print( "Pressed join existing game button..." )
        storyboard.gotoScene( "join_game", "fromLeft", 300 )
    end
end

local quickGameButtonHandler = function (event )
    if event.phase == "release" then
        print( "Pressed play quick game button..." )
        _G.controller.quickGame(_G.game_settings.session_id, _G.current_location, quickGameEventHandler)
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	local bg = display.newImageRect(_G.image_path .. "home_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	
	local quick_game_button = widget.newButton{
		id = "quick_game_button",
        default = _G.image_path .. "btn_play.png",
        over = _G.image_path .. "btn_play_over.png",
        width = 255, height = 240,
        onEvent = quickGameButtonHandler
	}
	quick_game_button:setReferencePoint(display.CenterReferencePoint)
	quick_game_button.x = stage.contentWidth/2
    quick_game_button.y = stage.contentHeight/2 - quick_game_button.height/5

	
	
	--local new_game_button = widget.newButton{
	--	id = "new_game_button",
    --    default = _G.image_path .. "btn_createNewGame.png",
    --    over = _G.image_path .. "btn_createNewGame.png",
    --    width = 200, height = 165,
    --    onEvent = newGameButtonHandler
	--}
	--new_game_button:setReferencePoint(display.CenterReferencePoint)
	--new_game_button.x = stage.contentWidth/2
    --new_game_button.y = stage.contentHeight*1/4
	--
	--
	--local join_game_button = widget.newButton{
	--	id = "join_game_button",
    --    default = _G.image_path .. "btn_joinTheGame.png",
    --    over = _G.image_path .. "btn_joinTheGame.png",
    --    width = 200, height = 165,
    --    onEvent = joinGameButtonHandler
	--}
	--join_game_button:setReferencePoint(display.CenterReferencePoint)
	--join_game_button.x = stage.contentWidth/2
    --join_game_button.y = stage.contentHeight*2/3

	-- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( quick_game_button )
	--group:insert( new_game_button )
	--group:insert( join_game_button )
		
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)
	
end


-- BEGIN GUI LAYOUT --



-- END GUI LAYOUT --


-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene