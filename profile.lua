-----------------------------------------------------------------------------------------
--
-- view2.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local scene = storyboard.newScene()
local stage = display.getCurrentStage()
local json = require("json")

local gui
local email_field, password_field
local email_label, password_label
local login_button

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------


local function textFieldEventHandler (textField)
	print ("goodbye")
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
	
	        --print( event.newCharacters )
	        --print( event.oldText )
	        --print( event.startPosition )
	        io.write("editing")
	        print("editing")
	        io.flush();
	
	    end
	end
end

local loginResponseHandler = function (event)
	if ( event.isError ) then
		print( "!!! There was an error making the login request !!!")
		print ( "RESPONSE: " .. event.response )
    else
		if (event.status == 200) then
			print ("Login succesful...")
			print ( "RESPONSE: " .. event.response )
			local data = {}
			data = json.decode(event.response);
			_G.game_settings.session_id = data["session_id"]
			saveData(_G.game_settings, "scatter_settings.json")
		end
    end
end

local loginButtonHandler = function (event )
    if event.phase == "release" then
        print( "You are logging in, mofo." )
        if (email_field.text ~= "" and password_field.text ~= "") then
        	_G.game_settings.email = email_field.text
        	_G.game_settings.password = password_field.text
        	saveData(_G.game_settings, "scatter_settings.json")
        	print("E-mail saved: " .. _G.game_settings.email)
        	print("Password saved: " .. _G.game_settings.password)	
        	local params = {}
        	local headers = {}
        	local data = {}
        	data["email"] = _G.game_settings.email
        	data["password"] = _G.game_settings.password
        	headers["Content-Type"] = "application/json; charset=utf-8"
        	headers["Accept-Language"] = "en-US"
        	headers["Accept"] = "application/json"
        	params.headers = headers
        	params.body = json.encode(data)
        	print(params.body)
        	network.request( "http://localhost:3000/api/v1/tokens", "POST", loginResponseHandler, params)
        end
    end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )	-- white
	
	-- create some text
	local title = display.newRetinaText( "Profile", 0, 0, native.systemFont, 32 )
	title:setTextColor( 0 )	-- black
	title:setReferencePoint( display.CenterReferencePoint )
	title.x = display.contentWidth * 0.5
	title.y = 20
	
	-- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( title )
	
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	email_label = display.newText( "E-mail", _G.gui_padding, _G.gui_padding*4, native.systemFont, _G.label_text_size )
	email_label:setTextColor( 255, 150, 180, 255 )
	
	email_field = native.newTextField(_G.gui_padding, email_label.y + email_label.height, stage.contentWidth - 2*_G.gui_padding, _G.text_field_height)
	email_field.inputType = "email"
	email_field:addEventListener ("userInput", textFieldEventHandler ( function() return email_field end ) )
	
	password_label = display.newText( "Password", _G.gui_padding, email_field.y + email_field.height, native.systemFont, _G.label_text_size )
	password_label:setTextColor( 255, 150, 180, 255 )
	
	password_field = native.newTextField(_G.gui_padding, password_label.y + email_label.height, stage.contentWidth - 2*_G.gui_padding, _G.text_field_height)
	password_field.inputType = "default"
	password_field.isSecure = true
	password_field:addEventListener ("userInput", textFieldEventHandler ( function() return password_field end ) )
		
	login_button = widget.newButton{
		default = "assets/images/btnBlueMedium.png",
		over = "assets/images/btnBlueMediumOver.png",
		onEvent = loginButtonHandler,
		label = "Login",
		labelColor = { default = { 255, 255, 255 } },
		fontSize = 18,
		emboss = true
	}
	
	
	login_button.x = stage.contentWidth/2
	login_button.y = password_field.y + password_field.height + 4*_G.gui_padding
	
	group:insert(email_label);
	group:insert(password_label);
	group:insert(login_button);

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	email_field:removeSelf()
	password_field:removeSelf()
	login_button:removeSelf()
	email_label:removeSelf()
	password_label:removeSelf()
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