-----------------------------------------------------------------------------------------
--
-- join_game.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require( "json" )
local controller = require("com.scatter.controller") 
local utilities = require("com.scatter.utilities") 
local scene = storyboard.newScene()
local stage = display.getCurrentStage()
local game_list_data = {}
_G.game_list = {}

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local function joinGameEventHandler(event)
	native.setActivityIndicator(false)
	if ( event.isError ) then
    	print( "Network error!" )
    	print ("RESPONSE: " .. event.response )
    else
    	print ( "RESPONSE: " .. event.response )
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response);
        	_G.channel_id = data["channel_id"]
        	_G.controller.subscribeToGameChannel(_G.client_id, _G.channel_id, _G.subscribeToGameChannelEventHandler)
        end        
    end
end

local function backButtonEventHandler(event )
    if event.phase == "release" then
		print("Back button pressed...")
    	storyboard.gotoScene( storyboard.getPrevious(), "fromLeft", 300 )    
    end
end

-- onEvent listener for the tableView
local function onGameListRowTouch( event )
        local row = event.target
        local row_group = event.view

        if event.phase == "press" then
                if not row.isCategory then row_group.alpha = 0.5; end

        elseif event.phase == "swipeLeft" then
                print( "Swiped left." )

        elseif event.phase == "swipeRight" then
                print( "Swiped right." )

        elseif event.phase == "release" then
            if not row.isCategory then
                row.reRender = true
                print( "Touched row #" .. event.index )
                print( "Attempting to join game: " .. row.title.text .. " with game_id: " .. row.game_id)
                _G.controller.joinGame(row.game_id, joinGameEventHandler)                        
            end
        end

        return true
end

-- onRender listener for the tableView
local function onGameListRowRender( event )
        local row = event.target
        local row_group = event.view
        local row_index = row.index or 0
        local color = 0
        
        row.background = display.newImage("assets/images/listItemBg.png")
        
        row.game_id = game_list_data[row_index].game_id
        
        row.title = display.newRetinaText(game_list_data[row_index].name, 0, 0, "Helvetica", 16)
        row.title:setTextColor(color)
        row.title:setReferencePoint(display.CenterLeftReferencePoint)
        row.title.x = 20
        row.title.y = row_group.contentHeight * 0.35
        
        row.subtitle = display.newRetinaText(game_list_data[row_index].city .. ", " .. game_list_data[row_index].state, 0, 0, "Helvetica", 16)
        row.subtitle:setTextColor(rowColor)
        row.subtitle:setReferencePoint(display.CenterLeftReferencePoint)
        row.subtitle.x = 20
        row.subtitle.y = row_group.contentHeight * 0.65
        
        -- must insert everything into event.view:
        
        row_group:insert( row.background )
        row_group:insert( row.title )
        row_group:insert( row.subtitle )
end

local function addGameEventHandler(event)
	table.insert(game_list_data, event.game)
	
	_G.game_list:insertRow {
            onEvent=onGameListRowTouch,
            onRender=onGameListRowRender,
            --height=60,
            --isCategory=false,
            --rowColor=0,
            --lineColor=lineColor
    }
end

local function removeGameEventHandler(event)
	table.insert(game_list_data, event.game)
	
	_G.game_list:insertRow {
            onEvent=onGameListRowTouch,
            onRender=onGameListRowRender,
            --height=60,
            --isCategory=false,
            --rowColor=0,
            --lineColor=lineColor
    }
end


local function getActiveGamesEventHandler(event)
	native.setActivityIndicator(false)
	
	if ( event.isError ) then
    	print( "!!! An error occured when getting list of active games !!!")
    	print ( "RESPONSE: " .. event.response )
    else
    	print( "List of active games retrieved successfully...")
    	print ( "RESPONSE: " .. event.response )
        if (event.status == 200) then
        	local data = {}
        	data = json.decode(event.response)
        	for i=1, table.getn(data.games), 1 do
        		local g = {}
        		g.game_id = data.games[i].id
        		g.name = data.games[i].id
        		g.city = "Tempe"
        		g.state = "AZ"
        		table.insert(game_list_data, g)
        		_G.game_list:insertRow {
		            onEvent=onGameListRowTouch,
		            onRender=onGameListRowRender,
		        }
		        if (i == 5) then
		        	i = table.getn(data.games)
		        end
        	end
        end
        
    end
end


-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	_G.controller.getActiveGames(getActiveGamesEventHandler)
	
	local title_bar = utilities.createTitleBar("Join Game", backButtonEventHandler) 
	
	-- create a white background to fill screen
	local bg = display.newRect( 0, title_bar.height, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )	-- white
	
	_G.game_list = widget.newTableView()
	_G.game_list.y = title_bar.height
	
	_G.game_list:addEventListener("addGame", addGameEventHandler)
	_G.game_list:addEventListener("removeGame", removeGameEventHandler)
	
	-- create some text
	--local title =- display.newRetinaText( "Start Screen", 0, 0, native.systemFont, 32 )
	--title:setText-Color( 0 )	-- black
	--title:setRefe-rencePoint( display.CenterReferencePoint )
	--title.x = dis-play.contentWidth * 0.5
	--title.y = 125-
	
	

	-- all objects must be added to group (e.g. self.view)

	group:insert( bg )
	group:insert( _G.game_list )
	group:insert( title_bar )
	
	--group:insert( title )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view	
	-- Do nothing
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