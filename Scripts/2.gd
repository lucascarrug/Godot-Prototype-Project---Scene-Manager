extends Control

@onready var scene2 = $"."

func _ready() -> void:
	scene2.size = get_viewport_rect().end
	Refs.viewport_x = get_viewport_rect().end.x
	Refs.viewport_y = get_viewport_rect().end.y

func _on_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/1.tscn")
