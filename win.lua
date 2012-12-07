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

local winners = {}
local losers = {}

local background, title, play_again_button

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------



local playAgainButtonHandler = function (event)
    if event.phase == "release" then
	    local options = {
			effect="slideLeft",
			time = 300,
		}
	    storyboard.gotoScene("home", options)
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	bg = display.newImageRect(_G.image_path .. "score_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	--title = display.newImageRect(_G.image_path .. "title_chooseAvatar.png", 220, 40)
	--title:setReferencePoint(display.CenterReferencePoint)
	--title.x = stage.contentWidth/2; title.y = 4*_G.gui_padding;
	
	
	play_again_button = widget.newButton{
		id = "continue_loss_button",
        default = _G.image_path .. "score_btn_playAgain.png",
        over = _G.image_path .. "score_btn_playAgain_over.png",
        width = 115, height = 90,
        onEvent = playAgainButtonHandler
	}
	play_again_button:setReferencePoint(display.CenterReferencePoint)
	play_again_button.x = stage.contentWidth/2
    play_again_button.y = stage.contentHeight - play_again_button.height - _G.gui_padding
    
    winners = game:getWinningAvatars()
    print("Winning Avatars: ")
    utilities.printTable(winners)
    
    
    group:insert( bg )
	--group:insert( title )
	group:insert( play_again_button )
    
    for i=1, #winners do
    	
		local avatar = display.newImageRect(_G.image_path .. "score_icon_" .. winners[i] ..".png", 85, 100)
		avatar:setReferencePoint(display.TopLeftReferencePoint)
		local score_icon = display.newImageRect(_G.image_path .. "score_iconMini_" .. winners[i] ..".png", 50, 55)
		score_icon:setReferencePoint(display.TopLeftReferencePoint)
		score_icon.x = 55
		score_icon.y = 4.5*_G.gui_padding + (i-1)*score_icon.height
		local eggplant = display.newImageRect(_G.image_path .. "score_eggplant.png", 50, 50)
		eggplant:setReferencePoint(display.TopLeftReferencePoint)
		eggplant.x = 120
		eggplant.y = 5.5*_G.gui_padding + (i-1)*score_icon.height
		local score = display.newRetinaText("X " .. #winners - (i-1) ,0,0, _G.fonts[2] ,20)
		score:setReferencePoint(display.CenterReferencePoint)
		score.x = eggplant.x + eggplant.width + 2.5*_G.gui_padding
		score.y = eggplant.y + eggplant.height/2
		--score:setTextColor(_G.colors["purple"][1],_G.colors["purple"][2],_G.colors["purple"][3],_G.colors["purple"][4])
		score:setTextColor(0)
		
		if (i == 1) then
			avatar.x = 5
			avatar.y = stage.contentHeight - 277		
		elseif (i == 2) then
			avatar.x = 85
			avatar.y = stage.contentHeight - 257
		elseif (i == 3) then
			avatar.x = 160
			avatar.y = stage.contentHeight - 239		
		end
		
		group:insert(score_icon)
		group:insert(eggplant)
		group:insert(score)
		group:insert(avatar)
		
    end
    
    if game:hasLoser() then
    	losers = game:getLosingAvatars()
    	print("Losing Avatars: ")
    	utilities.printTable(losers)
    	local avatar = display.newImageRect(_G.image_path .. "score_iconCharred_" .. losers[1] ..".png", 85, 160)
		avatar:setReferencePoint(display.TopLeftReferencePoint)
		avatar.x = 235
		avatar.y = stage.contentHeight - 274
		group:insert(avatar)
    end
   
	
    		
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	game = event.params.game
	
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
    storyboard.purgeScene( "win" )
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