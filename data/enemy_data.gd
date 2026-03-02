class_name EnemyData extends Resource
# 继承自Resource的类要求所有的属性都通过@export暴露出来

const DROP_HEIGHT := 50

@export var door_index: int
@export var type: Character.Type
@export var global_position: Vector2
@export var height: int
@export var state: Character.State

func _init(
	character_type: Character.Type = Character.Type.PUNK,
	position: Vector2 = Vector2.ZERO,
	assigned_door_index: int = -1,
) -> void:
	type = character_type
	door_index = assigned_door_index
	if position.y < 0:
		height = DROP_HEIGHT
		global_position = position + Vector2.DOWN * DROP_HEIGHT
		state = Character.State.DROP
	else:
		global_position = position
		state = Character.State.IDLE
