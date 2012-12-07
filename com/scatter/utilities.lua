local json = require("json")
local widget = require("widget")


local Utilities = {}
local utilities_mt = { __index = Utilities }	-- metatable

function Utilities.saveData(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end

function Utilities.loadData(filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         myTable = json.decode(contents);
         io.close( file )
    end
    return myTable
end

function Utilities.getDistanceBetween(l1, l2)
	local radius = 6371 --of earth in km
	local dLat = math.rad(l2.latitude-l1.latitude)
	local dLon = math.rad(l2.longitude-l1.longitude)
	local lat1 = math.rad(l1.latitude)
	local lat2 = math.rad(l2.latitude)
	
	local a = math.sin(dLat/2) * math.sin(dLat/2) + math.sin(dLon/2) * math.sin(dLon/2) * math.cos(lat1) * math.cos(lat2); 
	local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
	local d = radius * c
	
	return d
end

function Utilities.urlEncode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end
 
function Utilities.urlDecode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end


function Utilities.createTitleBar(title, backButtonEventHandler)
	local toolbarGradient = graphics.newGradient( {168, 181, 198, 255 }, {139, 157, 180, 255}, "down" )
	
	local title_bar = widget.newTabBar{
            top = 0,
            topGradient = toolbarGradient,
            bottomFill = { 117, 139, 168, 255 },
            height = 44
    }
    
    local back_button = widget.newButton{
            label = "Back",
            onRelease = backButtonEventHandler,
            height = 20,
            width = 40,
            cornerRadius = 5,       
    }
    back_button:setReferencePoint(display.CenterReferencePoint)
    title_bar:insert(back_button)
    back_button.x = back_button.width/2 + _G.gui_padding
    back_button.y = title_bar.height/2
    
    return title_bar
end

function Utilities.printTable(table) 
	for k in pairs(table) do print("Key: " .. k .. ", Value: " ..  tostring(table[k]) ) end
end

return Utilities