class_name Stage extends Node2D

@export var music: MusicManager.Music

var is_finished_stage := false

@onready var containers: Node2D = $Containers
@onready var doors: Node2D = $Doors
@onready var checkpoints: Node2D = $Checkpoints
@onready var player_spawn_location: Node2D = $PlayerSpawnLocation


func _init() -> void:
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())


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
	MusicPlayer.play(music)


func get_player_spawn_location() -> Vector2:
	return player_spawn_location.position


func on_checkpoint_complete(checkpoint: Checkpoint) -> void:
	if checkpoint == checkpoints.get_child(-1):
		is_finished_stage = true
		StageManager.stage_complete.emit()
