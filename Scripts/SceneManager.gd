extends Node

signal content_finished_loading(content)
signal content_invalid(content_path: String)
signal content_failed_to_load(content_path: String)
signal finished_loading_new_scene

var loading_screen: LoadingScreen
var _loading_screen_scene: PackedScene = preload("res://Scenes/LoadingScreen.tscn")

var _transition: String
var _scene_to_load: String
var _load_scene_into: Node
var _scene_to_unload: Node
var _load_progress_timer: Timer

var is_loading_in_progress := false

func _ready() -> void:
	# Connect signals.
	content_finished_loading.connect(on_content_finished_loading)
	content_invalid.connect(on_content_invalid)
	content_failed_to_load.connect(on_content_failed_to_load)
	finished_loading_new_scene.connect(on_finished_loading_new_scene)

func load_new_scene(scene_to_load: String, load_into: Node = null, scene_to_unload: Node = null, transition_type: String = "fade_in") -> void:
	# Check if is loading another scene at the moment.
	if is_loading_in_progress:
		printerr("Can't load a new scene while loading a new one.")
		return
	# Start loading.
	is_loading_in_progress = true
	# Save data.
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload
	_transition = transition_type
	# Create and add loading screen.
	loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(loading_screen)
	# Start animation.
	loading_screen.start_transition(transition_type)
	_load_content(scene_to_load)

func _load_content(scene_to_load: String) -> void:
	# Wait midpoint.
	await loading_screen.transition_reached_midpoint
	
	# Start loading new scene in thread.
	_scene_to_load = scene_to_load
	var loader = ResourceLoader.load_threaded_request(scene_to_load)
	
	if not ResourceLoader.exists(scene_to_load) or loader == null:
		content_invalid.emit(scene_to_load)
		return
	
	# Execute monitor_load_status every 0.1 seconds.
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()
	
func monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_scene_to_load, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			content_invalid.emit(_scene_to_load)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if loading_screen != null:
				loading_screen.update_bar(load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			content_failed_to_load.emit(_scene_to_load)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			# Send content.
			content_finished_loading.emit(ResourceLoader.load_threaded_get(_scene_to_load).instantiate())

func on_content_failed_to_load(path: String) -> void:
	printerr("error: Failed to load a resource ", path)
	
func on_content_invalid(path: String) -> void:
	printerr("error: Cannot load resource ", path)
	
func on_content_finished_loading(content) -> void:
	# Delete old scene.
	_scene_to_unload.queue_free()
	
	# Add and set new scene.
	_load_scene_into.call_deferred("add_child", content)
	_load_scene_into.set_deferred("current_scene", content)
	
	# Do the end transition.
	if loading_screen == null:
		return
	loading_screen.end_transition()
	await loading_screen.animation_player.animation_finished
	loading_screen.queue_free()
	finished_loading_new_scene.emit()

func on_finished_loading_new_scene() -> void:
	is_loading_in_progress = false
	print("Scene loaded.")
