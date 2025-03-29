extends Sprite2D

@export var amplitude_degrees: float = 15.0
@export var frequency: float = 4.0
@export var damping: float = 2.0
@export var energy_gain: float = 1.0
@export var energy_max: float = 5.0

var time := 0.0
var swing_energy := 0.0
var swing_direction := 1.0

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.is_pressed()):
		if texture == null:
			return

		var local_pos = to_local(event.position)
		var tex_size = texture.get_size() * scale.abs()
		var origin = -tex_size / 2.0 + offset
		var sprite_rect = Rect2(origin, tex_size)

		#if sprite_rect.has_point(local_pos):
			# Определяем направление в зависимости от стороны
		swing_energy = clamp(swing_energy + energy_gain, 0.0, energy_max)
		time = 0.0

func _process(delta: float) -> void:
	if swing_energy > 0.001:
		time += delta
		var decay = exp(-damping * time)
		var current_amplitude = amplitude_degrees * swing_energy * decay
		rotation_degrees = sin(time * frequency) * current_amplitude

		swing_energy *= exp(-damping * delta)

		if swing_energy < 0.001:
			rotation_degrees = 0.0
			swing_energy = 0.0
			time = 0.0
