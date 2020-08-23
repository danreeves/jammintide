extends KinematicBody2D

var peer_id
var speed = 500
var friction = 5000
var velocity = Vector2()
puppet var remote_pos = Vector2()

func _ready() -> void:
	pass

func init(player_peer_id):
	peer_id = player_peer_id
	$Name.text = Network.get_players()[peer_id].name

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_pressed("player_left"):
			velocity.x = -speed
		if Input.is_action_pressed("player_right"):
			velocity.x = speed
		if Input.is_action_pressed("player_up"):
			velocity.y = -speed
		if Input.is_action_pressed("player_down"):
			velocity.y = speed
		
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.y = move_toward(velocity.y, 0, friction * delta)
	
		# warning-ignore:return_value_discarded
		move_and_slide(velocity, Vector2(0, -1))
		
		rset_unreliable("remote_pos", position)
	else:
		position = remote_pos
		
