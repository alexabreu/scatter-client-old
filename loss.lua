-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local utilities = require( "com.scatter.utilities" )

local scene = storyboard.newScene()
local stage = display.getCurrentStage()


local background, title, continue_button, avatar

local delicious_sound = audio.loadSound(_G.sound_path .. "delicious.aif")

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------



local continueButtonHandler = function (event)
    if event.phase == "release" then
	    local options = {
			effect="slideLeft",
			time = 300,
			params = {game = game},
		}
	    storyboard.gotoScene("win", options)
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	bg = display.newImageRect(_G.image_path .. "loser_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	title = display.newImageRect(_G.image_path .. "loser_title_gameOver.png", 175, 55)
	title:setReferencePoint(display.CenterReferencePoint)
	title.x = stage.contentWidth/2; title.y = 4*_G.gui_padding;
	
	
	continue_button = widget.newButton{
		id = "continue_loss_button",
        default = _G.image_path .. "loser_btn_continue.png",
        over = _G.image_path .. "loser_btn_continue_over.png",
        width = 115, height = 90,
        onEvent = continueButtonHandler
	}
	continue_button:setReferencePoint(display.CenterReferencePoint)
	continue_button.x = stage.contentWidth/2
    continue_button.y = stage.contentHeight - continue_button.height - _G.gui_padding
    
    
    avatar = display.newImageRect(_G.image_path .. "loser_icon_".. _G.game_settings.avatar_id ..".png", 110, 95)
	avatar:setReferencePoint(display.CenterReferencePoint)
	avatar.x = stage.contentWidth - 80
	avatar.y = stage.contentHeight/2 + 25
    
    
    group:insert( bg )
	group:insert( title )
	group:insert( continue_button )
	group:insert( avatar )
	
    		
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	game = event.params.game
	
	local function playDeliciousSound()
		audio.play(delicious_sound)
	end
	
	timer.performWithDelay(1000, playDeliciousSound, 1)
	
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

function scene:didExitScene( event )
    storyboard.purgeScene( "loss" )
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

scene:addEventListener( "didExitScene" )

-----------------------------------------------------------------------------------------

return scene