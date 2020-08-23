extends Control

func _ready() -> void:
	# warning-ignore:return_value_discarded
	Network.connect("players_update", self, "update_players")
	update_players()
	
	if Network.is_server():
		$StartButton.visible = true
		# warning-ignore:return_value_discarded
		$StartButton.connect("button_down", self, "start_game")
	
func update_players():
	var text = ''
	var players = Network.get_players()
	for i in players:
		var player = players[i]
		text = text + str(i) + ": " + player.name + "\n"
	$Players.text = text

func start_game():
	SceneManager.rpc("go_to_level", "One")
