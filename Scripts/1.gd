extends Control


func _on_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/2.tscn", "slide_in")
