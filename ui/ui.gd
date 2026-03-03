class_name UI extends CanvasLayer

@export var duration_enemy_dispear: float

@onready var player_health_bar: HealthBar = $UIContainer/PlayerHealthBar
@onready var enemy_health_bar: HealthBar = $UIContainer/EnemyHealthBar
@onready var enemy_avatar: TextureRect = $UIContainer/EnemyAvatar
@onready var time_dispear := DurationTool.new(duration_enemy_dispear)

const avatar_map := {
	Character.Type.PUNK: preload("res://assets/art/ui/avatars/avatar-punk.png"),
	Character.Type.GOON: preload("res://assets/art/ui/avatars/avatar-goon.png"),
	Character.Type.THUG: preload("res://assets/art/ui/avatars/avatar-thug.png"),
	Character.Type.BOUNCER: preload("res://assets/art/ui/avatars/avatar-boss.png"),
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())

func _ready() -> void:
	set_enemy_visible(false)

func _process(_delta: float) -> void:
	if time_dispear.is_over_duration():
		set_enemy_visible(false)

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

func set_enemy_visible(value: bool) -> void:
	enemy_avatar.visible = value
	enemy_health_bar.visible = value
