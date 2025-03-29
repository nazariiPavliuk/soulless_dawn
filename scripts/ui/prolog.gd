extends Node2D

@export var frames: Array[StoryFrame] = []
@export var fade_duration: float = 1.0
@export var display_duration: float = 3.0
@export var next_scene: PackedScene

var current_index := 0
var fading := false
var skip_requested := false

func _ready():
	set_process_input(true)
	_show_current_frame()

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.is_pressed()):
		print("⏩ Скип получен")
		skip_requested = true

func _show_current_frame():
	if current_index >= frames.size():
		if frames.size() > 0:
			_fade_out_frame(frames[frames.size() - 1])
			await _wait_or_skip(fade_duration)
		if next_scene:
			get_tree().change_scene_to_packed(next_scene)
		return

	if current_index > 0:
		_fade_out_frame(frames[current_index - 1])

	var frame = frames[current_index]
	_set_frame_alpha(frame, 0.0)
	_set_frame_visible(frame, true)
	_fade_in_frame(frame)

	fading = true
	skip_requested = false

	await _wait_or_skip(fade_duration + display_duration)

	fading = false
	current_index += 1

	_show_current_frame()

func _wait_or_skip(duration: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		if skip_requested:
			return
		await get_tree().process_frame
		elapsed += get_process_delta_time()

func _set_frame_visible(frame: StoryFrame, visible: bool):
	for path in frame.nodes:
		var node = get_node(path)
		node.visible = visible

func _set_frame_alpha(frame: StoryFrame, alpha: float):
	for path in frame.nodes:
		var node = get_node(path)
		if node.has_method("set_modulate"):
			var color = node.get("modulate")
			color.a = alpha
			node.set("modulate", color)

func _fade_in_frame(frame: StoryFrame):
	for path in frame.nodes:
		var node = get_node(path)
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 1.0, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _fade_out_frame(frame: StoryFrame):
	for path in frame.nodes:
		var node = get_node(path)
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
