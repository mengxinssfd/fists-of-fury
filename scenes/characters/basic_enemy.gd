class_name BasicEnemy
extends Character

## 两次攻击间的间隔时间，单位 ms
@export var duration_between_hits : int
## 攻击前的准备时间，单位 ms
@export var duration_prep_hits : int
@export var player : Player

var player_slot: EnemySlot = null
var time_since_last_hit := Time.get_ticks_msec()
var time_since_prep_hit := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	anim_attacks = [
		"punch",
		"punch_alt",
	]


func handle_input() -> void:
	if player != null and can_move():
		if player_slot == null:
			player_slot = player.reserve_slot(self)
		else:
			var direction := (player_slot.global_position - global_position).normalized()
			if is_player_within_range():
				velocity = Vector2.ZERO
				if can_attack():
					set_state(State.PREP_ATTACK)
					time_since_prep_hit = Time.get_ticks_msec()
			else:
				velocity = direction * speed

func handle_prep_attack() -> void:
	if state_is(State.PREP_ATTACK) and Time.get_ticks_msec() - time_since_prep_hit > duration_prep_hits:
		set_state(State.ATTACK)
		time_since_last_hit = Time.get_ticks_msec()
		anim_attacks.shuffle()
		

func on_receive_damage(dmg: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void :
	super.on_receive_damage(dmg, direction, hit_type)
	if current_health == 0:
		player.free_slot(self)
		player_slot = null
		

# 判断是否在可攻击距离
func is_player_within_range() -> bool:
	return (player_slot.global_position - global_position).length() < 1

func set_handing() -> void:
	if not player:
		return
	# 倒地时不调整面向
	if state_is(State.GROUNDED):
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT
	

func can_attack() -> bool:
	if Time.get_ticks_msec() - time_since_last_hit < duration_between_hits:
		return false
	return super.can_attack()
