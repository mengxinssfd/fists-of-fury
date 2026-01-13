class_name BasicEnemy
extends Character

const EDGE_SCREEN_BUFFER := 10

## 两次近战攻击间的间隔时间，单位 ms
@export var duration_between_melee_attacks : int
## 两次远距离攻击间的间隔时间，单位 ms
@export var duration_between_range_attacks : int
## 近战攻击前的准备时间，单位 ms
@export var duration_prep_melee_attack : int
## 远距离攻击前的准备时间，单位 ms
@export var duration_prep_range_attack : int
@export var player : Player

var player_slot: EnemySlot = null
var time_since_last_melee_attack := Time.get_ticks_msec()
var time_since_prep_melee_attack := Time.get_ticks_msec()
var time_since_last_range_attack := Time.get_ticks_msec()
var time_since_prep_range_attack := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	anim_attacks = [
		"punch",
		"punch_alt",
	]


func handle_input() -> void:
	if can_move():
		if has_knife or can_respawn_knives or has_gun:
			goto_range_position()
		else:
			goto_melee_position()

func goto_range_position() -> void:
	if player == null: return
	var camera := get_viewport().get_camera_2d()
	var screen_width := get_viewport_rect().size.x - EDGE_SCREEN_BUFFER * 2
	var screen_edge_l := camera.position.x - screen_width / 2.0
	var screen_edge_r := camera.position.x + screen_width / 2.0

	var left_destination := Vector2(screen_edge_l, player.position.y)
	var right_destination := Vector2(screen_edge_r, player.position.y)

	var closest_destination := Vector2.ZERO

	if (left_destination - position).length() > (right_destination - position).length():
		closest_destination = right_destination
	else:
		closest_destination = left_destination

	if (closest_destination - position).length() < 1:
		velocity = Vector2.ZERO
	else:
		velocity = (closest_destination - position).normalized() * speed

	if can_range_attack() and (has_knife or has_gun) and projectile_aim.is_colliding():
		#set_state(State.PREP_ATTACK) # 按理来说应该先准备再攻击的
		if has_knife:
			set_state(State.THROW)
			time_since_last_range_attack = Time.get_ticks_msec()
			time_since_knife_dismiss = Time.get_ticks_msec()
		elif has_gun:
			#set_state(State.SHOOT)
			set_state(State.PREP_SHOOT)
			time_since_prep_range_attack = Time.get_ticks_msec()
func goto_melee_position() -> void:
	if not player: return

	if can_pickup_collectible():
		set_state(State.PICKUP)
		free_player_slot()
	elif player_slot == null:
		player_slot = player.reserve_slot(self)

	if player_slot != null:
		var direction := (player_slot.global_position - global_position).normalized()
		if is_player_within_range():
			velocity = Vector2.ZERO
			if can_attack():
				set_state(State.PREP_ATTACK)
				time_since_prep_melee_attack = Time.get_ticks_msec()
		else:
			velocity = direction * speed

func handle_prep_attack() -> void:
	if (
		state_is(State.PREP_ATTACK) and
		Time.get_ticks_msec() - time_since_prep_melee_attack > duration_prep_melee_attack
	):
		set_state(State.ATTACK)
		time_since_last_melee_attack = Time.get_ticks_msec()
		anim_attacks.shuffle()

func handle_prep_shoot() -> void:
	if (
		state_is(State.PREP_SHOOT) and
		Time.get_ticks_msec() - time_since_prep_range_attack > duration_prep_range_attack
	):
		shoot_gun()
		time_since_last_range_attack = Time.get_ticks_msec()

func on_receive_damage(dmg: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void :
	super.on_receive_damage(dmg, direction, hit_type)
	if current_health == 0 and player != null:
		free_player_slot()


# 判断是否在可攻击距离
func is_player_within_range() -> bool:
	return (player_slot.global_position - global_position).length() < 1

func set_handing() -> void:
	if not player or not can_move(): return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT


func can_attack() -> bool:
	if (
		Time.get_ticks_msec() - time_since_last_melee_attack < duration_between_melee_attacks
	): return false
	return super.can_attack()

func can_range_attack() -> bool:
	if (
		Time.get_ticks_msec() - time_since_last_range_attack < duration_between_range_attacks
	): return false
	return super.can_attack()

func free_player_slot() -> void:
	player.free_slot(self)
	player_slot = null
