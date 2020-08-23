extends Node

var peers_done_loading = []

func go_to(name: String):
	print("res://scenes/" + name + ".tscn")
	var world = load("res://scenes/" + name + ".tscn").instance()
	world.name = 'world'
	var root = get_node("/root")
	var current_world = get_node_or_null("/root/world")
	if current_world:
		root.remove_child(current_world)
	root.add_child(world)

remotesync func go_to_level(name: String):
	peers_done_loading = []
	get_tree().set_pause(true)
	
	var level = "Levels/" + name
	go_to(level)
	
	var own_peer_id = get_tree().get_network_unique_id()
	var own_player = preload("res://scenes/Entities/Player.tscn").instance()
	own_player.name = str(own_peer_id)
	own_player.init(own_peer_id)
	own_player.set_network_master(own_peer_id)
	get_node("/root/world/players").add_child(own_player)
	
	for peer_id in Network.peers:
		var player = preload("res://scenes/Entities/Player.tscn").instance()
		player.name = str(peer_id)
		player.init(peer_id)
		player.set_network_master(peer_id)
		get_node("/root/world/players").add_child(player)
	
	if Network.is_server():
		if peers_done_loading.size() == Network.peers.size():
			rpc("start_level")
	else:
		rpc_id(Network.SERVER_PEER_ID, "done_loading")

remote func done_loading():
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in Network.peers) # Exists
	assert(not who in peers_done_loading) # Was not added yet

	peers_done_loading.append(who)

	if peers_done_loading.size() == Network.peers.size():
		rpc("start_level")
		
remotesync func start_level():
	print("start_level")
	# Only the server is allowed to tell a client to unpause
	if Network.SERVER_PEER_ID == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		# Game starts now!
