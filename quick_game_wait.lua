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

local current_player_count = nil
local game = {}

local bg, text, cancel_quick_game_button, current_player_count

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local function newPlayerEventListener( event )
	utilities.printTable(event)
	game.current_player_count = event.current_player_count
    current_player_count.text = event.current_player_count .. " / " .. game.total_player_count
end

local function playerLeaveEventListener( event )
	utilities.printTable(event)
	game.current_player_count = event.current_player_count
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


local cancelQuickGameButtonHandler = function (event )
    if event.phase == "release" then
        print( "Pressed cancel quick game button..." )
        game:leaveBeforeStart()
        _G.tab_bar:pressButton( 1, true )
    end
end



-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	bg = display.newImageRect(_G.image_path .. "home_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	text = display.newImageRect(_G.image_path .. "title_waiting.png", 180, 140)
	text:setReferencePoint(display.TopLeftReferencePoint)
	text.x = stage.contentWidth/2 - text.width/2; text.y = stage.contentHeight/3 - text.height;
	text:setReferencePoint(display.CenterReferencePoint)
	
	current_player_count = display.newRetinaText("",0,0, _G.fonts[2] ,80)
	current_player_count:setReferencePoint(display.CenterReferencePoint)
	current_player_count.x = text.x
	current_player_count.y = text.y + text.height
	current_player_count:setTextColor(_G.colors["purple"][1],_G.colors["purple"][2],_G.colors["purple"][3],_G.colors["purple"][4])
	
	
	cancel_quick_game_button = widget.newButton{
		id = "cancel_quick_game_button",
        default = _G.image_path .. "btn_cancel.png",
        over = _G.image_path .. "btn_cancel_over.png",
        width = 115, 
        height = 90,
        onEvent = cancelQuickGameButtonHandler
	}
	cancel_quick_game_button:setReferencePoint(display.CenterReferencePoint)
	cancel_quick_game_button.x = stage.contentWidth/2
    cancel_quick_game_button.y = _G.tab_bar.y - cancel_quick_game_button.height - 2*_G.gui_padding
	
	
	-- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( text )
	group:insert( current_player_count )
	group:insert( cancel_quick_game_button )
 
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	game = event.params.game

	game:addEventListener( "game#join", newPlayerEventListener )
	game:addEventListener( "game#leave", playerLeaveEventListener )
	game:addEventListener( "game#started", gameStartEventListener )
	
	current_player_count.text = game.current_player_count .. " / " .. game.total_player_count

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	game:removeEventListener( "game#join", newPlayerEventListener )
	game:removeEventListener( "game#leave", playerLeaveEventListener )
	game:removeEventListener( "game#started", gameStartEventListener )
	
	current_player_count.text = ""
	
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