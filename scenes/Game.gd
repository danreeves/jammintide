extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("go_to_menu")
	
func go_to_menu():
	SceneManager.go_to("Menus/Server")
