extends Node2D

const STAGE_01_STREETS = preload("res://scenes/stage/stage_01_streets.tscn")
const STAGE_02_BAR = preload("res://scenes/stage/stage_02_bar.tscn")
const PLAYER = preload("res://scenes/characters/player.tscn")

const STAGES = [STAGE_01_STREETS, STAGE_02_BAR]

var is_camara_locked := false
var stage_index := -1
var player: Player
var camara_init_position := Vector2.ZERO
var is_stage_ready_for_loading := false

@onready var stage_container: Node2D = $StageContainer
@onready var actors_container: Node2D = $ActorsContainer
@onready var camera := $Camera


func _ready() -> void:
	StageManager.checkpoint_start.connect(on_checkpoint_start.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.stage_complete.connect(load_next_stage.bind())
	camara_init_position = camera.position
	load_next_stage()


func _process(_delta: float) -> void:
	if is_stage_ready_for_loading:
		is_stage_ready_for_loading = false
		init_player_and_camara()
	if player and not is_camara_locked and player.position.x > camera.position.x:
		camera.position.x = player.position.x


func load_next_stage() -> void:
	stage_index += 1
	if stage_index < STAGES.size():
		for c in actors_container.get_children():
			if not (c is Player):
				c.queue_free()
		for c in stage_container.get_children(): c.queue_free()
		is_stage_ready_for_loading = true


func init_player_and_camara() -> void:
	var stage: Stage = STAGES[stage_index].instantiate()
	stage_container.add_child(stage)
	if not player:
		player = PLAYER.instantiate()
		actors_container.add_child(player)
		actors_container.player = player
	player.position = stage.get_player_spawn_location()
	camera.position = camara_init_position


func on_checkpoint_start() -> void:
	is_camara_locked = true


func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	is_camara_locked = false
