extends Control

@onready var scene1 = $"."

func _ready() -> void:
	scene1.size = get_viewport_rect().end

func _on_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/2.tscn", "slide_in")
