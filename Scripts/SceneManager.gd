extends Node

const HEIGHT := 700
const WIDTH := 1200

signal content_finished_loading(content)
signal content_invalid(content_path: String)
signal content_failed_to_load(content_path: String)

var loading_screen: LoadingScreen
var _loading_screen_scene: PackedScene = preload("res://Scenes/LoadingScreen.tscn")
var _transition: String
var _content_path: String
var _load_progress_timer: Timer

func _ready() -> void:
	content_finished_loading.connect(on_content_finished_loading)
	content_invalid.connect(on_content_invalid)
	content_failed_to_load.connect(on_content_failed_to_load)
	
func load_new_scene(content_path: String, transition_type: String = "fade_in") -> void:
	# Save transition.
	_transition = transition_type
	# Create loading screen.
	loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(loading_screen)
	# Start animation.
	loading_screen.start_transition(transition_type)
	_load_content(content_path)

func _load_content(content_path: String) -> void:
	# Wait midpoint.
	print("Esperando midpoint en", loading_screen)
	await loading_screen.transition_reached_midpoint
	
	# Start loading new scene.
	_content_path = content_path
	var loader = ResourceLoader.load_threaded_request(content_path)
	if not ResourceLoader.exists(content_path) or loader == null:
		content_invalid.emit(content_path)
		return
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()
	
func monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			content_invalid.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if loading_screen != null:
				#loading_screen.update_bar(load_progress[0] * 100)
				pass
		ResourceLoader.THREAD_LOAD_FAILED:
			content_failed_to_load.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			# Send content.
			content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())

func on_content_failed_to_load(path: String) -> void:
	printerr("error: Failed to load a resource ", path)
	
func on_content_invalid(path: String) -> void:
	printerr("error: Cannot load resource ", path)

func on_content_finished_loading(content) -> void:
	var outgoing_scene = get_tree().current_scene
	
	# Delete old scene.
	outgoing_scene.queue_free()
	
	# Add and set new scene.
	get_tree().root.call_deferred("add_child", content)
	get_tree().set_deferred("current_scene", content)
	
	# Do the end transition.
	if loading_screen == null:
		return
	loading_screen.end_transition()
	await loading_screen.animation_player.animation_finished
	loading_screen = null
