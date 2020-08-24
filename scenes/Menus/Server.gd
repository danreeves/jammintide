extends Node

func _ready() -> void:
	# warning-ignore:return_value_discarded
	$ConnectButton.connect("button_down", self, "connect_to_server")
	# warning-ignore:return_value_discarded
	$CreateButton.connect("button_down", self, "create_server")
	$Name.text = PlayerProfile.name
	# warning-ignore:return_value_discarded
	$Name.connect("text_changed", self, "update_name")
	
	$ProfileSelect.add_item("Kruber", 1)
	$ProfileSelect.add_item("Kerillian", 2)
	$ProfileSelect.selected = PlayerProfile.profile_id - 1
	$ProfileSelect.connect("item_selected", self, "select_profile")
	
func create_server():
	var port = int($Port2.text)
	Network.create_server(port, 4)
	SceneManager.go_to("Menus/Lobby")
	
func connect_to_server():
	var ip = $IP.text
	var port = int($Port.text)
	Network.connect_to_server(ip, port)
	SceneManager.go_to("Menus/Lobby")

func update_name():
	if ($Name.text != ""):
		PlayerProfile.name = $Name.text
		PlayerProfile.save_profile()

func select_profile(profile_index):
	PlayerProfile.profile_id = profile_index + 1
	PlayerProfile.save_profile()
