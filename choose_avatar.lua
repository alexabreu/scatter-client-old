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


local avatars = {}

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------



local avatarButtonHandler = function (event)
    --utilities.printTable(event)
    if event.phase == "ended" then
        print( "Pressed avatar button..." )
        _G.game_settings.avatar_id = event.target.avatar_id
        print("Selected avatar_id: " .. _G.game_settings.avatar_id )
        utilities.saveData(_G.game_settings, "scatter_settings.json")
        local options = {
			effect="slideLeft",
			time = 300,
		}
        _G.tab_bar:pressButton( 1, true )
        --if (event.target.avatar_id == 1) then
        --	 
        --elseif (event.target.avatar_id == 2) then
        --
        --elseif (event.target.avatar_id == 3) then
        --
        --elseif (event.target.avatar_id == 4) then
        --
        --end
       
    end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	local bg = display.newImageRect(_G.image_path .. "home_bg.png", 320, 480)
	bg:setReferencePoint(display.TopLeftReferencePoint)
	bg.x = 0; bg.y = 0;
	bg:setReferencePoint(display.CenterReferencePoint)
	
	local title = display.newImageRect(_G.image_path .. "title_chooseAvatar.png", 220, 40)
	title:setReferencePoint(display.CenterReferencePoint)
	title.x = stage.contentWidth/2; title.y = 4*_G.gui_padding;
	
	
	group:insert( bg )
	group:insert( title )
	
	for i = 1, 4 do
		avatars[i] = widget.newButton {
			id = "avatar" .. i,
	        default = _G.image_path .. "icon_" .. i .. ".png",
	        over = _G.image_path .. "icon_" .. i .. "_over.png",
	        width = 125, 
	        height = 160,
		}
		avatars[i]["avatar_id"] = i
		avatars[i]:setReferencePoint(display.TopLeftReferencePoint)
		if (i == 1) then
			avatars[i].x = 2*_G.gui_padding
			avatars[i].y = title.y + _G.gui_padding
		elseif (i == 2) then
			avatars[i].x = stage.contentWidth - avatars[i].width - 2*_G.gui_padding
			avatars[i].y = title.y + _G.gui_padding
		elseif (i == 3) then
			avatars[i].x = 2*_G.gui_padding
			avatars[i].y = avatars[1].y + avatars[1].height + 3*_G.gui_padding
		elseif (i == 4) then
			avatars[i].x = stage.contentWidth - avatars[i].width - 2*_G.gui_padding
			avatars[i].y = avatars[2].y + avatars[2].height + 3*_G.gui_padding
		end
		
		avatars[i]:addEventListener("touch", avatarButtonHandler)
		group:insert(avatars[i])
			
	end
		
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