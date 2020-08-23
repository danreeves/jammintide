extends Node

onready var ConnectButton = $ConnectButton
onready var CreateButton = $CreateButton

func _ready() -> void:
	ConnectButton.connect("button_down", self, "connect_to_server")
	CreateButton.connect("button_down", self, "create_server")
	
	
func create_server():
	var port = int($Port2.text)
	Network.create_server(port, 4)
	SceneManager.go_to("Menus/Lobby")
	
func connect_to_server():
	var ip = $IP.text
	var port = int($Port.text)
	Network.connect_to_server(ip, port)
	SceneManager.go_to("Menus/Lobby")
