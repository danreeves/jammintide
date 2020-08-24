extends Node

const PATH = "user://player_profile.json"

var profile_id = 1

func _ready() -> void:
	load_profile()
	if name == "PlayerProfile":
		name = "unknown"

func to_dict():
	return {
		name = name,
		profile_id = profile_id
	}
	
func save_profile():
	var player_profile = File.new()
	player_profile.open(PATH, File.WRITE)
	player_profile.store_line(to_json(to_dict()))
	player_profile.close()
	
func load_profile():
	var player_profile = File.new()
	if not player_profile.file_exists(PATH):
		print(PATH + " not found!")
		return
	
	player_profile.open(PATH, File.READ)
	var data = parse_json(player_profile.get_line())
	for key in data:
		print(key)
		print(data[key])
		self[key] = data[key]
