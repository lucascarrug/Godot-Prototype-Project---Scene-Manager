extends Control

func _on_down_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/Down.tscn", get_tree().root, self, "slide_up_in")


func _on_up_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/Up.tscn", get_tree().root, self, "slide_down_in")


func _on_right_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/Right.tscn", get_tree().root, self, "slide_left_in")


func _on_left_button_pressed() -> void:
	SceneManager.load_new_scene("res://Scenes/Left.tscn", get_tree().root, self, "slide_right_in")
