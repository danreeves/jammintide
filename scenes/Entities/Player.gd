extends KinematicBody2D

export var MIN_POINTER_DISTANCE = 15
export var MAX_POINTER_DISTANCE = 100
export var POINTER_DISTANCE_LERP_SPEED = 15

var peer_id
var speed = 500
var friction = 5000
var velocity = Vector2()

puppet var remote_pos = Vector2()
puppet var moving = false
puppet var jumping = false

const max_airtime = 0.5
var airtime = 0

func _ready() -> void:
	pass

func init(player_peer_id: int) -> void:
	peer_id = player_peer_id
	var profile = Network.get_players()[peer_id]
	$Name.bbcode_text = "[center]" + profile.name + "[/center]"
	print(profile)
	if profile.profile_id == 2:
		$Sprite.modulate = "#00ff00"

func _physics_process(delta: float) -> void:
	movement(delta)
	aim(delta)
	
func aim(delta: float) -> void:
	if is_network_master():
		var mouse_pos = get_global_mouse_position()
		$Center.global_rotation = lerp_angle(
			$Center.global_rotation, 
			mouse_pos.angle_to_point($Center.global_position), 
			delta * POINTER_DISTANCE_LERP_SPEED
		)
		var distance = clamp(
			$Center.global_position.distance_to(mouse_pos), 
			MIN_POINTER_DISTANCE, 
			MAX_POINTER_DISTANCE
		)
		$Center/Aim.position.x = lerp($Center/Aim.position.x, distance, delta * POINTER_DISTANCE_LERP_SPEED)

func movement(delta: float) -> void:
	if is_network_master():
		moving = false
		if Input.is_action_pressed("player_left"):
			velocity.x = -speed
			moving = true
		if Input.is_action_pressed("player_right"):
			velocity.x = speed
			moving = true
		if Input.is_action_pressed("player_up"):
			velocity.y = -speed
			moving = true
		if Input.is_action_pressed("player_down"):
			velocity.y = speed
			moving = true
		
		if Input.is_action_just_pressed("player_jump"):
			airtime = 0
			set_collision_layer_bit(0, false)
			set_collision_layer_bit(1, true)
			set_collision_mask_bit(0, false)
			set_collision_mask_bit(1, true)
			z_index = 2
			$Sprite.offset = Vector2(0, -50)
			jumping = true
			
		if jumping:
			airtime = airtime + delta
		
		if airtime >= max_airtime:
			jumping = false
			$Sprite.offset = Vector2(0, 0)
			z_index = 0
			set_collision_layer_bit(0, true)
			set_collision_layer_bit(1, false)
			set_collision_mask_bit(0, true)
			set_collision_mask_bit(1, false)
		
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.y = move_toward(velocity.y, 0, friction * delta)
	
		# warning-ignore:return_value_discarded
		move_and_slide(velocity, Vector2(0, -1))
		
		rset_unreliable("remote_pos", position)
		rset_unreliable("moving", moving)
	else:
		position = remote_pos
