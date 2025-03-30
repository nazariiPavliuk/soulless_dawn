# player.gd
extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_velocity: float = -300.0
@export var gravity: float = 900.0
@export var destination_margin: float = 5.0
@export_range(0.0, 0.01, 0.00001)
var vertical_scale_factor: float = 0.002
@export var stuck_threshold: float = 5.0

@export var health_bar: NodePath
@export var animated_sprite: NodePath
@export var feet_marker: NodePath

var health: int = 20
var max_health: int = 20

var target_position: Vector2 = Vector2.ZERO
var attacking: bool = false
var is_jumping: bool = false

@onready var sprite: AnimatedSprite2D = get_node(animated_sprite)
@onready var health_ui = get_node(health_bar)
@onready var feet = get_node(feet_marker)

func _ready():
	target_position = feet.global_position
	_update_health_bar()

func _physics_process(delta):
	# Свободное перемещение в любую сторону (без гравитации)
	var feet_pos = feet.global_position
	var to_target = target_position - feet_pos

	if to_target.length() > destination_margin:
		var direction = to_target.normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	var old_position = global_position
	move_and_slide()
	var movement = global_position.distance_to(old_position)

	# Если почти не двигаемся — возможно упёрлись
	if movement < stuck_threshold * delta:
		target_position = feet_pos
		velocity = Vector2.ZERO
		if not attacking:
			_play_animation("idle")
	elif velocity.length() > 0.0:
		sprite.flip_h = velocity.x < 0
		if not attacking:
			_play_animation("run")
	else:
		if not attacking:
			_play_animation("idle")

	# Масштаб по вертикали (визуальная глубина)
	var screen_center = get_viewport_rect().size.y / 2
	var scale_offset = (screen_center - global_position.y) * vertical_scale_factor
	scale = Vector2(1.0 - scale_offset, 1.0 - scale_offset)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_attack()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var world_pos = get_viewport().get_canvas_transform().affine_inverse() * event.position
			target_position = world_pos

func _attack():
	if not attacking:
		attacking = true
		_play_animation("fight")
		sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished():
	attacking = false

func _play_animation(name: String):
	if sprite.animation != name:
		sprite.play(name)

func take_damage(amount: int):
	health = max(0, health - amount)
	_update_health_bar()
	_play_animation("damage")

func _update_health_bar():
	if health_ui.has_method("set_value"):
		health_ui.call("set_value", health)
