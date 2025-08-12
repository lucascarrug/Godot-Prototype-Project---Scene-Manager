extends Control

func _on_center_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/Center.tscn", get_tree().root, self, "slide_right_in")
