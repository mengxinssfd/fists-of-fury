class_name Player
extends Character

@onready var enemy_slots : Array = $EnemySlots.get_children()

func handle_input() -> void:
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	#position += direction * delta * speed
	velocity = direction * speed

	if can_attack() and Input.is_action_just_pressed("attack"):
		set_state(State.ATTACK)
		attack_combo_index = (attack_combo_index + 1) % anim_attacks.size()
		print(attack_combo_index)
	if can_jump() and Input.is_action_just_pressed("jump"):
		set_state(State.TAKEOFF)
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
