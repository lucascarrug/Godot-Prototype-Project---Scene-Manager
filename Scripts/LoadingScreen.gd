class_name LoadingScreen extends CanvasLayer

signal transition_reached_midpoint

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var progress_bar = $Control/ProgressBar

var current_animation_name: String

func _ready() -> void:
	progress_bar.visible = false
	
func start_transition(start_animation_name: String) -> void:
	# Check if animaition exists or default start.
	if not animation_player.has_animation(start_animation_name):
		push_warning(start_animation_name, " doesn't exist.")
		start_animation_name = "fade_in"
	
	# Run animation.
	current_animation_name = start_animation_name
	animation_player.play(current_animation_name)
	
	# If timer reaches timeout, show progress bar.
	timer.start()
	
func end_transition() -> void:
	# Default end.
	var end_animaition_name = "fade_out"
	
	# Play animation.
	current_animation_name = end_animaition_name
	animation_player.play(end_animaition_name)
	
	# Wait animation.
	await animation_player.animation_finished
	queue_free()

func report_midpoint() -> void:
	transition_reached_midpoint.emit()

func update_bar(value) -> void:
	progress_bar.value = value

func _on_timer_timeout() -> void:
	progress_bar.visible = true
