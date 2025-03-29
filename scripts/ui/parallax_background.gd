extends ParallaxBackground

@export var sensitivity: float = 0.05  # множитель чувствительности

func _process(delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Центрируем мышку относительно экрана (-0.5 до 0.5)
	var offset = (mouse_pos / viewport_size) - Vector2(0.5, 0.5)
	
	# Применяем чувствительность
	scroll_offset = offset * sensitivity * viewport_size
