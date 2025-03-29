extends Button

@export var target_scene: PackedScene  # сцена, на которую переходим

func _on_start_pressed() -> void:
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)
