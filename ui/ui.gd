class_name UI extends CanvasLayer

const avatar_map := {
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png"),
}

@export var duration_enemy_dispear: float

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


func on_combo_reset(points: int) -> void:
	score_indicator.add_combo(points)


func on_character_health_change(
	character_type: Character.Type,
	current_health: int,
	max_health: int,
) -> void:
	if character_type == Character.Type.PLAYER:
		player_health_bar.refresh(current_health, max_health)
	else:
		time_dispear.refresh()
		enemy_avatar.texture = avatar_map[character_type]
		enemy_health_bar.refresh(current_health, max_health)
		set_enemy_visible(true)


func on_checkpoint_complete() -> void:
	go_indicator.start_flickering()


func set_enemy_visible(value: bool) -> void:
	enemy_avatar.visible = value
	enemy_health_bar.visible = value
