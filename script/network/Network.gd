extends Node

signal players_update

const SERVER_PEER_ID = 1

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")

var peers = {}

# TODO: Move to a PlayerProfile global
var my_info = { name = "rain" }

func create_server(port = 13337, max_players = 4):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	get_tree().network_peer = peer
	
func connect_to_server(ip, port):
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_client(ip, port) == OK:
		get_tree().network_peer = peer
	
func get_players():
	var players = peers.duplicate(true)
	players[get_tree().get_network_unique_id()] = my_info
	return players
	
func is_server():
	return get_tree().is_network_server()

func is_client():
	return !is_server()

func _player_connected(id):
	# Someone connected, let them know about myself
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	peers.erase(id)

func _connected_ok():
	pass

func _server_disconnected():
	print("The server kicked us.")

func _connected_fail():
	print("Failed to connect to the server.")

remotesync func register_player(data):
	var id = get_tree().get_rpc_sender_id()
	peers[id] = data
	emit_signal("players_update")
