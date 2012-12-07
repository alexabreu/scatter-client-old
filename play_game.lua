-----------------------------------------------------------------------------------------
--
-- view1.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local utilities = require( "com.scatter.utilities" )
local scene = storyboard.newScene()
local current_location
local stage = display.getCurrentStage()
local top_bar, broadcast_button, weapon_button, game_clock_bg, clock_time
local seconds = display.newGroup()
local game = {}
local ping_location_timer = nil
local game_clock_timer = nil
local warning_displayed = false
local clock_started = false
local broadcast_sound = audio.loadSound(_G.sound_path .. "broadcast.aif")
local broadcast_button_sound = audio.loadSound(_G.sound_path .. "broadcast_button.aif")
local drum_sound = audio.loadSound(_G.sound_path .. "drum.aif")
local drum_channel

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------


local function toggleBroadcastButton()
	if broadcast_button.isVisible then 
		broadcast_button.isVisible = false
	else
		broadcast_button.isVisible = true
	end
end


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
    	print( "!!! Error pinging location !!!" )
    	print ("RESPONSE: " .. event.response )
    else
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response);	
        	if (data ~= nil) then
        		--print ("Successfully pinged location...")
        		--print(event.response)
        	else
        		print ("!!! Failed to ping location properly !!!")
        	end
        end        
    end
end


local broadcastButtonHandler = function (event )
    if event.phase == "ended" then
        print( "Pressed broadcast button..." )
        
        audio.play(broadcast_button_sound)
        
        toggleBroadcastButton()
       		
        _G.controller.broadcastLocation(game, _G.current_location, broadcastLocationEventHandler)
    end
end


local pingLocation = function()
	_G.controller.pingLocation(game, _G.current_location, pingLocationEventHandler)
end


local pulseClockTime = function()
	drum_channel = audio.play(drum_sound, {loops=-1, fadein=( game.game_time - game.elapsed_time )*1000 } )
	for i = 1, 3 do
		print("pulse")
		transition.to( seconds, { delay=i*1000, time=500, alpha=0, } )
		transition.to( seconds, { delay=i*1000+500, time=500, alpha=0.5, } )
	end
end

local stopClock = function(message)
	timer.cancel(game_clock_timer)
	clock_started = false
	transition.to( seconds, { time=500, alpha=0, rotation=360 } )
	
	clock_time.text = message
	clock_time.isVisible = true
end

local resetClock = function()
	for i=seconds.numChildren, 1, -1 do 
		seconds[i]:removeSelf()
		seconds[i] = nil
	end
	
	stopClock(game.game_time/60 .. " : 00")
end

local drawClockTime = function()
	clock_started = true
	game.elapsed_time = game.elapsed_time + 1
	local second = display.newRect(seconds, 0, 0, 360/game.game_time, game_clock_bg.height - 32)
	second:setReferencePoint(display.BottomCenterReferencePoint)
	second.x = game_clock_bg.x
	second.y = game_clock_bg.y
	second:setFillColor(_G.colors["purple"][1], _G.colors["purple"][2], _G.colors["purple"][3], 0.5*_G.colors["purple"][4])
	second:rotate(game.elapsed_time*360/game.game_time)
	seconds:setReferencePoint(display.BottomLeftReferencePoint)
	
	if ( game.elapsed_time >= 0.75*game.game_time and not warning_displayed ) then
		print("pulsing time")
		warning_displayed = true
		pulseClockTime()
	elseif ( game.elapsed_time == game.game_time ) then
		audio.stop(drum_channel)	
		event = {}
		event.name = "touch"
		event.phase = "ended"
		broadcast_button:dispatchEvent(event)
				
		stopClock("Time!")
	end
	
end

local startClockTime = function()
	print("Starting game timer...")
	clock_time.isVisible = false
	seconds.alpha = 1
	drawClockTime()
	broadcast_button.isVisible = true
	game_clock_timer = timer.performWithDelay(1000, drawClockTime, 0)
end


local function showLoss()
	local options = {
		effect="slideLeft",
		time = 300,
		params = {game = game},
	}
    storyboard.gotoScene("loss", options)
end

local function gameFinishEventListener( event )
	print("Game is over. Stopping the action...")
	
	stopClock("Game!")
	
	print("Your ID: " .. _G.game_settings.user_id)
	print("Winning IDs: ") 
	utilities.printTable(game.vertices);
	
	local function goHome()
		local options = {
			effect="slideLeft",
			time = 300,
		}
		storyboard.gotoScene("home", options)
	end
	
	if game.didLose(_G.game_settings.user_id) then
		print ("You Lost!!!")
		timer.performWithDelay(_G.game_end_delay_time, showLoss, 1)
	elseif game.hasLoser() then
		print ("You're one of the winners")
		timer.performWithDelay(_G.game_end_delay_time, showWin, 1)
	else
		
					
		timer.performWithDelay(_G.game_end_delay_time, goHome, 1)
	end
	
	
	--transition.to( _G.gMap, { time=500, delta=true, height=-13, y=-50} )
	--transition.to( continue_button, { time=300, y=display.contentHeight - _G.tab_bar.height} )
end


local function gameBroadcastEventListener( event )
	print ("Broadcast count: " .. game.broadcast_count .. "/" .. game.total_player_count)
	audio.play(broadcast_sound)
	if game.broadcast_count == game.total_player_count - 1  then
		if broadcast_button.isVisible then
			print ("Everyone else broadcasted, forcing self broadcast to end game!!!!")
			event = {}
			event.name = "touch"
			event.phase = "ended"
			broadcast_button:dispatchEvent(event)
		end
	end
end






-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
		
	game = event.params.game
	
	game_clock_bg = display.newImageRect(_G.image_path .. "topMenu_timer.png", 50, 50)
	game_clock_bg:setReferencePoint(display.TopLeftReferencePoint)
	game_clock_bg.x = 0; 
	game_clock_bg.y = 0;
	game_clock_bg:setReferencePoint(display.CenterReferencePoint)
		
	clock_time = display.newRetinaText(game.game_time/60 .. " : 00",0,0, _G.fonts[1] ,14)
	clock_time:setReferencePoint(display.CenterReferencePoint)
	clock_time.height = 14
	clock_time.x = game_clock_bg.x
	clock_time.y = game_clock_bg.y
	clock_time:setTextColor(_G.colors["purple"][1],_G.colors["purple"][2],_G.colors["purple"][3],_G.colors["purple"][4])

	top_bar = display.newImageRect(_G.image_path .. "topMenu_title.png", 170, 50)
	top_bar:setReferencePoint(display.TopLeftReferencePoint)
	top_bar.x = game_clock_bg.width;
	top_bar.y = 0;
	top_bar:setReferencePoint(display.CenterReferencePoint)
	
	broadcast_button_placeholder = display.newImageRect(_G.image_path .. "topMenu_broadcast_tapped.png", 50, 50)
	broadcast_button_placeholder:setReferencePoint(display.TopLeftReferencePoint)
	broadcast_button_placeholder.x = stage.contentWidth - broadcast_button_placeholder.width;
	broadcast_button_placeholder.y = 0;
	broadcast_button_placeholder:setReferencePoint(display.CenterReferencePoint)
	
	broadcast_button = widget.newButton {
		id = "broadcast_button",
		default = _G.image_path .. "topMenu_broadcast.png",
		over = _G.image_path .. "topMenu_broadcast_over.png",
		width = 50,
		height = 50,
	}
	broadcast_button:addEventListener("touch", broadcastButtonHandler)
	

	broadcast_button.x = stage.contentWidth - broadcast_button.width/2
	broadcast_button.y =  broadcast_button.height/2
	broadcast_button.isVisible = false
	
	
	weapon_button = widget.newButton {
		id = "broadcast_button",
		default = _G.image_path .. "topMenu_weapon.png",
		over = _G.image_path .. "topMenu_weapon_over.png",
		--onRelease = ,
		width = 50,
		height = 50,
	}

	weapon_button.x = broadcast_button.x - weapon_button.width
	weapon_button.y =  weapon_button.height/2
	
	
	--continue_button = widget.newButton{
    --    id = "btn001",
    --    left = 0,
    --    top = display.contentHeight + _G.tab_bar.height,
    --    label = "Continue",
    --    width = stage.contentWidth, 
    --    height = 50,
    --    cornerRadius = 0,
    --    onEvent = onButtonEvent
    --}
	--continue_button:setReferencePoint(display.TopLeftReferencePoint)
	
	group:insert(top_bar)
	group:insert(broadcast_button_placeholder)
	group:insert(weapon_button)
	group:insert(game_clock_bg)
	group:insert(clock_time)
	group:insert(seconds)
	group:insert( _G.gMap )
	group:insert( broadcast_button )
	--group:insert( continue_button )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	--transition.to( _G.tab_bar, { time=300, y=display.contentHeight + _G.tab_bar.height} )

	game = event.params.game
	
	game:addEventListener( "game#finished", gameFinishEventListener )
	game:addEventListener( "game#check_in", gameBroadcastEventListener )
	
	
	if (game.status == "started" and not clock_started) then
		timer.performWithDelay(1000, startClockTime, 1)
		broadcast_button.isVisible = false
	end
	
	pingLocation()
	ping_location_timer = timer.performWithDelay(5000, pingLocation, 0)
	
	_G.gMap.isVisible = true;
	
	
	
	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	game:removeEventListener( "game#finished", gameFinishEventListener )
	game:removeEventListener( "game#check_in", gameBroadcastEventListener )
	
	timer.cancel(ping_location_timer)
	
	_G.gMap.isVisible = false;
	
	if (game.status == "finished") then
		resetClock()
		toggleBroadcastButton()
	end
	
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