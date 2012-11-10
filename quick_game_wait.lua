-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local game = require( "com.scatter.game" )

local scene = storyboard.newScene()
local stage = display.getCurrentStage()

local current_player_count = nil
local game = {}

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local function newPlayerEventListener( event )
    current_player_count.text = event.current_player_count .. " / " .. game.total_player_count
end

local function gameStartEventListener( event )
	local options = {
		effect="slideLeft",
		time = 300,
		params = {game = game},
	}
    storyboard.gotoScene("play_game", options)
end



local function leaveGameEventHandler(event)
	native.setActivityIndicator(false)
	print(event.response)
	if ( event.isError ) then
    	print( "!!! Error leaving quick game !!!" )
    	print ("RESPONSE: " .. event.response )
    else
        if (event.status == 200) then
        	print( "Successfully left quick game before start..." )
        	print ("RESPONSE: " .. event.response )
        end        
    end
end


local cancelQuickGameButtonHandler = function (event )
    if event.phase == "release" then
        print( "Pressed cancel quick game button..." )
        _G.controller.leaveGame(leaveGameEventHandler)
        game:leaveBeforeStart()
        _G.tab_bar:pressButton( 1, true )
    end
end



-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	game = event.params.game
	
	print ("Waiting for players " .. game.current_player_count .. " of " .. game.total_player_count)
	
	game:addEventListener( "game#join", newPlayerEventListener )
	game:addEventListener( "game#started", gameStartEventListener )
	
	local bg = display.newImageRect(_G.image_path .. "home_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	local text = display.newImageRect(_G.image_path .. "home_wait.png", 195, 140)
	text:setReferencePoint(display.TopLeftReferencePoint)
	text.x = stage.contentWidth/2 - text.width/2; text.y = stage.contentHeight/3 - text.height;
	text:setReferencePoint(display.CenterReferencePoint)
	
	current_player_count = display.newRetinaText(game.current_player_count .. " / " .. game.total_player_count, 0, 0, text.width, 0, _G.fonts[1], 80)
	current_player_count:setReferencePoint(display.CenterReferencePoint)
	current_player_count.x = text.x
	current_player_count.y = text.y + text.height + 2*_G.gui_padding
	current_player_count:setTextColor(_G.colors["purple"][1],_G.colors["purple"][2],_G.colors["purple"][3],_G.colors["purple"][4])
	
	
	local cancel_quick_game_button = widget.newButton{
		id = "cancel_quick_game_button",
        default = _G.image_path .. "btn_cancel.png",
        over = _G.image_path .. "btn_cancel_over.png",
        width = 130, 
        height = 50,
        onEvent = cancelQuickGameButtonHandler
	}
	cancel_quick_game_button:setReferencePoint(display.CenterReferencePoint)
	cancel_quick_game_button.x = stage.contentWidth/2
    cancel_quick_game_button.y = _G.tab_bar.y - cancel_quick_game_button.height - 4*_G.gui_padding
	
	
	-- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( text )
	group:insert( current_player_count )
	group:insert( cancel_quick_game_button )
 
		
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