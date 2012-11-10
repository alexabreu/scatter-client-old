-----------------------------------------------------------------------------------------
--
-- create_game.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local controller = require("com.scatter.controller")
local utilities = require("com.scatter.utilities") 
local scene = storyboard.newScene()
local stage = display.getCurrentStage()
local game_name_label, game_name_field, play_button

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local function gameNameFieldEventHandler(textField)
	return function( event )		
		if event.phase == "began" then
	
	        -- user begins editing textField
	        print("begin")
	
	    elseif event.phase == "ended" then
	
	        -- textField/Box loses focus
	        print("end")
	    elseif event.phase == "ended" or event.phase == "submitted" then
	
	        -- do something with defaulField's text
	        print("submitted")
	        print(textField().text)

	        native.setKeyboardFocus( nil )
	    elseif event.phase == "editing" then
	    	if (textField().text ~= "") then
	    		play_button.isVisible = true
	    	else
	    		play_button.isVisible = false
	    	end
	
	    end
	end
end


local function createGameEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "Network error!")
    	print ( "Create game error: " .. event.response )
    else
    	print ( "Create game response: " .. event.response )
        if (event.status == 200) then
        	_G.in_game = true
        	local data = {}
        	data = json.decode(event.response)
        	_G.channel_id = data["channel_id"]
        	_G.controller.subscribeToGameChannel(_G.client_id, _G.channel_id, _G.subscribeToGameChannelEventHandler)
        end   
    end
end



local function newGameEventHandler(event )
    if event.phase == "release" then
		print("Play button pressed...")
    	_G.controller.createGame(game_name_field.text, 4, {}, createGameEventHandler)      
    end
end


local function backButtonEventHandler(event )
    if event.phase == "release" then
		print("Back button pressed...")
    	storyboard.gotoScene( storyboard.getPrevious(), "fromLeft", 300 )    
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	local bg = display.newImageRect(_G.image_path .. "home_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	group:insert( bg )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
  
	local title_bar = utilities.createTitleBar("New Game", backButtonEventHandler) 
	
	game_name_label = display.newText( "Group Name", _G.gui_padding, title_bar.height + _G.gui_padding, native.systemFont, _G.label_text_size )
	game_name_label:setTextColor( _G.colors["label"][1], _G.colors["label"][2], _G.colors["label"][3], _G.colors["label"][4])
	
	game_name_field = native.newTextField(_G.gui_padding, game_name_label.y + game_name_label.height, stage.contentWidth - 2*_G.gui_padding, _G.text_field_height)
	game_name_field.inputType = "default"
	game_name_field:addEventListener ("userInput", gameNameFieldEventHandler ( function() return game_name_field end ) )
		
	play_button = widget.newButton{
		default = "assets/images/btnBlueMedium.png",
		over = "assets/images/btnBlueMediumOver.png",
		onEvent = newGameEventHandler,
		label = "Play",
		labelColor = { default = { 255, 255, 255 } },
		fontSize = 18,
		emboss = true
	}
	
	play_button.x = stage.contentWidth/2;
	play_button.y =  stage.contentHeight/2
	play_button.isVisible = false

	group:insert( play_button )
	group:insert( title_bar )
	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	game_name_label:removeSelf()
	game_name_field:removeSelf()
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