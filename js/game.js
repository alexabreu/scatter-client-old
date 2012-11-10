var Game = function(params) {
	console.log("Constructing game...");
    //Array of players {id, avatar_id, lat, lng}
    this.players = [{id: 1, avatar_id: 1}];
    this.player_count = 0;
    this.map = params.map;
    this.location = {};
    this.checked_in_players = [];
}
   
    		
Game.prototype = {    

start : function(players, player_count, lat, lng) {
    this.players = players;
    this.player_count = player_count;
    this.location = {lat: lat, lng: lng, city: city};
    this.map.setCenter(new google.maps.LatLng(lat, lng));
},
    
addPlayer : function(player_id, avatar_id, lat, lng) {
    var player = {};
   	
   	player.id = player_id;
   	player.lat = lat;
   	player.lng = lng;
   	player.avatar_id = avatar_id;
   	
   		   		 	
		var icon = "";
		var shadow = "";
		switch(avatar_id) {
   		case 1:
   			icon = "assets/image_cuts/icon_1.png";
   			shadow = "assets/image_cuts/1con_1.png";
   		break;
   		
   		default:
   			icon = "assets/image_cuts/icon_1.png";
   			shadow = "assets/image_cuts/1con_1.png";
   		break;
		}
		
  	var marker = new google.maps.Marker({
      position: new google.maps.LatLng(lat, lng),
      map: this.map,
      //shadow: shadow,
      icon: icon
      //shape: shape,
      //title: beach[0],
      //zIndex: beach[3]
   });
   
   player.marker = marker;
   
   this.checked_in_players.push(player);
   
   this.zoomMapExtents();
 
   return player;
},

zoomMapExtents : function() {
    var total_lat = 0;
    var total_lng = 0;
    
    var checked_in_player_count = this.checked_in_players.length
    for (var i = 0; i < checked_in_player_count; i++) {
	    total_lat += this.checked_in_players[i].lat;
	    total_lng += this.checked_in_players[i].lng;
    }
    
    this.map.panTo(new google.maps.LatLng(total_lat/checked_in_player_count, total_lng/checked_in_player_count));
}


}
