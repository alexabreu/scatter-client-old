-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local scene = storyboard.newScene()
local current_location
local stage = display.getCurrentStage()
local top_bar, broadcast_button
local game = {}
local ping_location_timer = nil

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------


local function broadcastLocationEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "!!! Error broadcasting location !!!" )
    	print ("RESPONSE: " .. event.response )
    else
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response);	
        	if (data ~= nil) then
        		print ("Successfully broadcasted location...")
        		print(event.response)
        	else
        		print ("!!! Failed to broadcast location properly !!!")
        	end
        end        
    end
end


local function pingLocationEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "!!! Error broadcasting location !!!" )
    	print ("RESPONSE: " .. event.response )
    else
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response);	
        	if (data ~= nil) then
        		print ("Successfully pinged location...")
        		print(event.response)
        	else
        		print ("!!! Failed to ping location properly !!!")
        	end
        end        
    end
end


local broadcastButtonHandler = function (event )
    if event.phase == "release" then
        print( "Pressed broadcast button..." )
        _G.controller.broadcastLocation(game, _G.current_location, broadcastLocationEventHandler)
    end
end


local pingLocation = function()
	_G.controller.pingLocation(game, _G.current_location, pingLocationEventHandler)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
		
	game = event.params.game
	
	local top_bar = widget.newTabBar{
        top = 0,
        topGradient = {},
        bottomFill = { 117, 139, 168, 255 },
        height = 70
    }
	
	broadcast_button = widget.newButton {
		id = "broadcast_button",
		default = _G.image_path .. "btn_broadcast.png",
		over = _G.image_path .. "btn_broadcast_over.png",
		onEvent = broadcastButtonHandler,
		width = 65,
		height = 65,
	}

	broadcast_button.x = top_bar.x
	broadcast_button.y =  top_bar.y
	
	group:insert(top_bar)
	group:insert( _G.gMap )
	group:insert( broadcast_button )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	ping_location_timer = timer.performWithDelay(5000, pingLocation, 0)
	
	_G.gMap.isVisible = true;
	
	
	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	timer.cancel(ping_location_timer)
	
	_G.gMap.isVisible = false;
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)
	
end

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