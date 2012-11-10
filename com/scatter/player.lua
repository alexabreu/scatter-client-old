Player = {}
function Player:new(session_id)
	local player = {}
	player.session_id = session_id
	player.locations = {}
	player.avatar = ""
	return player
end
return Player