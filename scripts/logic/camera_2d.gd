extends Camera2D

@export var target_path: NodePath
@export var follow_x: bool = true
@export var follow_y: bool = true
@export var smoothing_speed: float = 5.0

#@export var limit_left: float = -1000.0
#@export var limit_right: float = 1000.0
#@export var limit_top: float = -1000.0
#@export var limit_bottom: float = 1000.0

var target_node: Node2D

func _ready():
	target_node = get_node(target_path)
	position = target_node.global_position
	make_current()

func _process(delta):
	if not target_node:
		return

	var target_pos = target_node.global_position
	var new_pos = global_position

	if follow_x:
		new_pos.x = target_pos.x
	if follow_y:
		new_pos.y = target_pos.y

	# Ограничения
	#new_pos.x = clamp(new_pos.x, limit_left, limit_right)
	#new_pos.y = clamp(new_pos.y, limit_top, limit_bottom)

	# Плавное движение
	global_position = global_position.lerp(new_pos, smoothing_speed * delta)
