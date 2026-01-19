class_name Player
extends Character

@onready var enemy_slots : Array = $EnemySlots.get_children()

## 连招重置间隔时间
@export var max_duration_between_successful_hits : int

## 上一次攻击击中时间
var time_since_last_successful_attack := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	anim_attacks = [
		"punch",
		"punch_alt",
		"kick",
		"roundkick",
	]

func _process(delta: float) -> void:
	super._process(delta)
	process_time_between_combo()

func process_time_between_combo() -> void:
	if Time.get_ticks_msec() - time_since_last_successful_attack > max_duration_between_successful_hits:
		attack_combo_index = 0

func handle_input() -> void:
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	# 非静止、行走、跳跃状态不接收移动输入
	# 如果允许跳、跳攻击接收输入的话，那就可以微调跳跃距离，否则是固定跳跃距离
	#if can_move() or state_in(State.JUMP, State.JUMPKICK):
	if can_move():
		velocity = direction * speed

	if can_attack() and Input.is_action_just_pressed("attack"):
		if has_knife:
			set_state(State.THROW)
		elif has_gun:
			#set_state(State.SHOOT)
			if ammo_left > 0:
				shoot_gun()
				ammo_left -= 1
			else:
				set_state(State.THROW)
		else:
			if can_pickup_collectible():
				set_state(State.PICKUP)
			else:
				set_state(State.ATTACK)
				if is_last_hit_successful:
					time_since_last_successful_attack = Time.get_ticks_msec()
					attack_combo_index = (attack_combo_index + 1) % anim_attacks.size()
					is_last_hit_successful = false
				else:
					attack_combo_index = 0
	if can_jump() and Input.is_action_just_pressed("jump"):
		set_state(State.TAKEOFF)
		attack_combo_index = 0
	if can_jumpkick() and Input.is_action_just_pressed("attack"):
		set_state(State.JUMPKICK)

func reserve_slot(enemy: BasicEnemy) -> EnemySlot:
	var available_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.is_free()
	)
	
	if available_slots.size() == 0:
		return null
		
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	
	var first = available_slots[0]
	first.occupy(enemy)
	return first
	
func free_slot(enemy: BasicEnemy) -> void:
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	if target_slots.size() == 1:
		target_slots[0].free_up()

func set_handing() -> void:
	if not can_move(): return
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT
