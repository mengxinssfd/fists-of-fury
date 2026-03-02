class_name Stage extends Node2D

@onready var containers: Node2D = $Containers
@onready var doors: Node2D = $Doors
@onready var checkpoints: Node2D = $Checkpoints

func _ready() -> void:
	# 重置父节点
	for container: Node2D in containers.get_children():
		EntityManager.orphan_actor.emit(container)
	for i in range(doors.get_child_count()):
		var door: Door = doors.get_child(i)
		door.assign_door_index(i)
		EntityManager.orphan_actor.emit(door)
	for checkpoint: Checkpoint in checkpoints.get_children():
		checkpoint.create_enemy_data()
