class_name LoadingScreen extends CanvasLayer

signal transition_reached_midpoint

@onready var animation_player := $AnimationPlayer
@onready var timer := $Timer
@onready var progress_bar := $Control/ProgressBar
@onready var control := $Control
var current_animation_name: String

func _ready() -> void:
	call_deferred("scale_control")
	
	progress_bar.visible = false
	
func scale_control() -> void:
	# Scale in order to addapt the loading screen.
	var scale_factor_x = control.size.x / float(Refs.viewport_x)
	var scale_factor_y = control.size.y / float(Refs.viewport_y)
	control.scale /= Vector2(scale_factor_x, scale_factor_y)

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
	# Make the inverse transition.
	var end_animaition_name = current_animation_name.replace("in", "out")
	
	# Check if exists or default end.
	if not animation_player.has_animation(end_animaition_name):
		push_warning(end_animaition_name, " doesn't exist.")
		end_animaition_name = "fade_out"
	
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
