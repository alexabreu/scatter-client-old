local controller = require("com.scatter.controller")
local game = require("com.scatter.game")
local player = require("com.scatter.player")
local utilities = require("com.scatter.utilities")
local widget = require("widget")
local storyboard = require("storyboard")
local json = require("json")


io.output():setvbuf("no")
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

_G.app_server = "http://playscatter.herokuapp.com/"
_G.message_server = "http://messagescatter.herokuapp.com/faye"
_G.image_path = "assets/images@2x/"
_G.load_time = 2500
_G.default_game_time = 5

_G.game_settings = {}
_G.current_location = {}
_G.current_address = {}
_G.locations = {}
_G.client_id = nil
_G.channel_id = nil
_G.message_id = 1
_G.in_game = false
_G.games_played = {}
_G.current_game = {}

_G.gui_padding = 10
_G.text_field_height = 30
_G.label_text_size = 20
_G.fonts = {}
_G.colors = {}
_G.colors["purple"] = {102, 51, 204, 255}
_G.colors["label"] = {121, 0, 202, 255}

_G.fonts[1] = "Grinched"

_G.tab_bar = {}


_G.controller = controller

_G.map = {}

local onSimulator = system.getInfo( "environment" ) == "simulator"
local platformVersion = system.getInfo( "platformVersion" )
local olderVersion = tonumber(string.sub( platformVersion, 1, 1 )) < 4


if onSimulator then
	_G.app_server = "http://localhost:3000/"
	_G.message_server = "http://localhost:9292/faye"
	_G.load_time = 0
end

-- if on older device (and not on simulator) ...
if not onSimulator and olderVersion then
	if string.sub( platformVersion, 1, 3 ) ~= "3.2" then
		_G.fonts[1] = "Helvetica"
	end
end



-- show default status bar (iOS)
--display.setStatusBar( display.DefaultStatusBar )
display.setStatusBar( display.HiddenStatusBar )


local function getSessionIDResponseHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "!!! An error occured when attempting to retrieve session ID !!!")
    	print ( "RESPONSE: " .. event.response )
    else
    	print( "Session ID retrieved succesfully...")
    	print ( "RESPONSE: " .. event.response )
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response);
        	_G.game_settings.session_id = data["session"]
        	utilities.saveData(_G.game_settings, "scatter_settings.json")
        end   
    end
end


local function handshakeWithMessageServerEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "!!! Error shaking hands with message server !!!")
    	print ( "RESPONSE: " .. event.response )
    else
    	print( "Succesfully shook hands with message server...")
    	print ( "RESPONSE: " .. event.response )
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response)[1];
        	_G.client_id = data["clientId"]
        	print("Client ID: " .. _G.client_id)
        	_G.controller.connectToGameChannel(_G.gameChannelEventHandler)
        end   
    end
end

function _G.subscribeToGameChannelEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "!!! Error subscribing to game channel !!!")
    	print ( "RESPONSE: " .. event.response )
    	_G.current_game["subscribed"] = false
    else
    	print( "Subscribed to game channel successfully...")
    	print ( "RESPONSE: " .. event.response )
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response)[1];	
        	_G.current_game["subscribed"] = true
        end   
    end
end

function _G.gameChannelEventHandler(event)
	if ( event.isError ) then
    	print( "!!! Timeout on connect, we just connect again !!!")
    	print ( "RESPONSE: " .. event.response )
        _G.controller.connectToGameChannel(_G.gameChannelEventHandler)
    else
    	print( "Polled message server successfully...")
    	print ( "RESPONSE: " .. event.response )
        if (event.status == 200) then
        	local response = {}
        	response = json.decode(event.response)
        	for i=1,table.getn(response) do
        		if (response[i].channel == _G.channel_id and response[i].data ~= nil) then
        			local data = response[i].data
        			local event = {}
        			event["name"] = data.event
        			if (data.event == "game#join") then
        				print ("Someone joined the game...")
        				utilities.printTable (data)
        				event["current_player_count"] = data.player_count
        			elseif (data.event == "game#started") then
        				print ("Game started...")
        				utilities.printTable (data)
        				event["lat"] = data.center[1]
        				event["lat"] = data.center[2]
        				event["width"] = data.width
        				event["height"] = data.height
        				
        			end
        			_G.current_game:dispatchEvent(event)
        		end
        	end
        	_G.controller.connectToGameChannel(_G.gameChannelEventHandler)
        end   
    end
end

function _G.mapAddressEventHandler( event )
    -- handle mapAddress event here
    if event.isError then
        print( "mapView Error: " .. event.errorMessage )
    else
    	_G.current_address = event
        --print( "The specified location is in: " .. event.city .. ", " .. event.region)
    end
end

function _G.locationEventHandler( event )
	_G.current_location = event
	print ("LAT: " .. event.latitude .. ", LNG: " .. event.longitude)
	_G.map:nearestAddress(_G.current_location.latitude, _G.current_location.longitude)
end

-- event listeners for tab buttons:

local function onHomeView( event )
	storyboard.gotoScene( "home", "fromLeft", 300 )
end

local function onCreateGameView( event )
	storyboard.gotoScene( "create_game", "fromLeft", 300 )
end

local function onPlayGameView( event )
	local options = {
		effect="slideLeft",
		time = 300,
		params = {game = game.new(1, 1, 4, 4, _G.default_game_time)},
	}
	storyboard.gotoScene( "play_game", options)
end

local function onJoinGameView( event )
	storyboard.gotoScene( "join_game", "fromLeft", 300 )
end

local function onProfileView( event )
	storyboard.gotoScene( "profile", "fromLeft", 300 )
end

local function onChooseAvatarView( event )
	storyboard.gotoScene( "choose_avatar", "fromLeft", 300 )
end

local function onQuickGameWaitView( event )
	local game = game.new(2, 3, 4, 1)
	local options = {
		effect="slideLeft",
		time = 300,
		params = {game = game},
	}
	storyboard.gotoScene( "quick_game_wait", options)
end

-- create a tab_bar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{up=_G.image_path.."btn_home.png", down=_G.image_path.."btn_home_over.png", width = 32, height = 32, onPress=onHomeView, selected=true },
	--{up="icon2.png", down="icon2-down.png", width = 32, height = 32, onPress=onCreateGameView, selected=true },
	--{up="icon1.png", down="icon1-down.png", width = 32, height = 32, onPress=onJoinGameView, selected=false},
	{up="icon1.png", down="icon1-down.png", width = 32, height = 32, onPress=onPlayGameView, selected=false},
	{up=_G.image_path.."btn_preference.png", down=_G.image_path.."btn_preference_over.png", width = 32, height = 32, onPress=onChooseAvatarView, selected=false},
	{up=_G.image_path.."btn_preference.png", down=_G.image_path.."btn_preference_over.png", width = 32, height = 32, onPress=onQuickGameWaitView, selected=false},	
}

_G.tab_bar = widget.newTabBar {
	top = display.contentHeight - 50,	-- 50 is default height for tab_bar widget
	buttons = tabButtons
}
	
-- create the actual tab_bar widget
local stage = display.getCurrentStage()

local splash = display.newGroup()
splash:setReferencePoint(display.TopLeftReferencePoint)
splash.x = 0; splash.y = 0;
splash:setReferencePoint(display.CenterReferencePoint)


local bg = display.newImageRect(splash, _G.image_path .. "home_bg.png", 320, 480)
bg:setReferencePoint(display.TopLeftReferencePoint)
bg.x = 0; bg.y = 0;
bg:setReferencePoint(display.CenterReferencePoint)

local logo = display.newImageRect(splash, _G.image_path .. "home_logo.png", 320, 480)
logo:setReferencePoint(display.TopLeftReferencePoint)
logo.x = 0; logo.y = 0;
logo:setReferencePoint(display.CenterReferencePoint)


_G.map = native.newMapView(0, 0, stage.contentWidth, stage.contentHeight - _G.tab_bar.height)
_G.map.isVisible = false
Runtime:addEventListener( "mapAddress", _G.mapAddressEventHandler )
Runtime:addEventListener( "location", _G.locationEventHandler )


_G.gMap = native.newWebView(0, 0, stage.contentWidth, stage.contentHeight - 2.5*_G.tab_bar.height)
_G.gMap:request( "map.html", system.ResourceDirectory )
_G.gMap.isVisible = false


_G.game_settings = utilities.loadData("scatter_settings.json")

if onSimulator then
	_G.game_settings = {}
end

if (_G.game_settings == nil or _G.game_settings.session_id == nil or _G.game_settings.session_id == "") then
	controller.getSessionID(getSessionIDResponseHandler)
end

controller.handshakeWithMessageServer(handshakeWithMessageServerEventHandler)

local function run()
	splash:removeSelf()
	splash = nil
	
	if (_G.game_settings.avatar_id == nil or _G.game_settings.session_id == "") then
		onChooseAvatarView()
	else
		onHomeView()	-- Go to game selection screen (aka "home")
	end
	
	
end

timer.performWithDelay(_G.load_time, run, 1)
