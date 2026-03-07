class_name UI extends CanvasLayer

const OPTIONS_SCREEN = preload("res://ui/options_screen.tscn")
const DEATH_SCREEN = preload("res://ui/death_screen.tscn")
const GAME_OVER_SCREEN = preload("res://ui/game_over_screen.tscn")

const avatar_map := {
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png"),
}

@export var duration_enemy_dispear: float

var options_screen: OptionsScreen = null
var death_screen: DeathScreen = null
var game_over_screen: GameOverScreen = null

@onready var player_health_bar: HealthBar = $UIContainer/PlayerHealthBar
@onready var enemy_health_bar: HealthBar = $UIContainer/EnemyHealthBar
@onready var enemy_avatar: TextureRect = $UIContainer/EnemyAvatar
@onready var combo_indicator: ComboIndicator = $UIContainer/ComboIndicator
@onready var score_indicator: Label = $UIContainer/ScoreIndicator
@onready var go_indicator: FlickeringTextureRect = $UIContainer/GoIndicator
@onready var time_dispear := DurationTool.new(duration_enemy_dispear)


func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())


func _ready() -> void:
	set_enemy_visible(false)
	combo_indicator.combo_reset.connect(on_combo_reset.bind())
	go_indicator.start_flickering()


func _process(_delta: float) -> void:
	if enemy_avatar.visible and time_dispear.is_over_duration():
		set_enemy_visible(false)
	handle_input()


func handle_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SoundPlayer.play(SoundManager.Sound.CLICK)
		if options_screen == null:
			var os := OPTIONS_SCREEN.instantiate()
			options_screen = os
			options_screen.exit.connect(unpauce.bind())
			add_child(os)
			get_tree().paused = true
		else:
			unpauce()


func unpauce() -> void:
	options_screen.queue_free()
	get_tree().paused = false


func on_combo_reset(points: int) -> void:
	score_indicator.add_combo(points)


func on_character_health_change(
	character_type: Character.Type,
	current_health: int,
	max_health: int,
) -> void:
	if character_type == Character.Type.PLAYER:
		player_health_bar.refresh(current_health, max_health)
		if current_health == 0 and death_screen == null:
			var ds: DeathScreen = DEATH_SCREEN.instantiate()
			ds.game_over.connect(on_game_over.bind())
			death_screen = ds
			add_child(ds)
	else:
		time_dispear.refresh()
		enemy_avatar.texture = avatar_map[character_type]
		enemy_health_bar.refresh(current_health, max_health)
		set_enemy_visible(true)


func on_game_over() -> void:
	var go: GameOverScreen = GAME_OVER_SCREEN.instantiate()
	game_over_screen = go
	go.set_score(score_indicator.real_score)
	add_child(go)


func on_checkpoint_complete() -> void:
	go_indicator.start_flickering()


func set_enemy_visible(value: bool) -> void:
	enemy_avatar.visible = value
	enemy_health_bar.visible = value
