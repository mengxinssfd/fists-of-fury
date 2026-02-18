class_name IgorBoss
extends Character

# 类似重力的地面摩擦力
const GROUND_FRICTION := 50

@export var distance_from_player: int
@export var duration_between_attacks: int
# 虚弱时长
@export var duration_vulerable: int
@export var player: Player

var knockback_force := Vector2.ZERO
var time_last_attack := Time.get_ticks_msec()
# 开始虚弱的时间
var time_start_vulerable := Time.get_ticks_msec()

func _process(delta: float) -> void:
	super._process(delta)
	# 慢慢归零
	knockback_force = knockback_force.move_toward(Vector2.ZERO, delta * GROUND_FRICTION)

func handle_input() -> void:
	if player == null or not can_move(): return
	if can_attack() and projectile_aim.is_colliding():
		set_state(State.FLY)
		velocity = heading * flight_speed
	else:
		if is_player_within_range(): 
			velocity = Vector2.ZERO
			set_state(State.IDLE)
		else:
			var target_destination := get_target_destination()
			var direction := (target_destination - position).normalized()
			velocity = (direction + knockback_force) * speed
			set_state(State.WALK)
	
func handle_grounded() -> void:
	if state_is(State.GROUNDED) and current_health > 0: 
		set_state(State.RECOVER)
		time_start_vulerable = Time.get_ticks_msec()
	elif state_is(State.RECOVER) and Time.get_ticks_msec() - time_start_vulerable > duration_vulerable:
		set_state(State.IDLE)
		time_last_attack = Time.get_ticks_msec()
		

func set_handing() -> void:
	if player == null or not can_move(): return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT

func get_target_destination() -> Vector2:
	var direct := Vector2.LEFT if position.x < player.position.x else Vector2.RIGHT
	return player.position + direct * distance_from_player

func is_player_within_range() -> bool:
	return (get_target_destination() - position).length() < 1

func can_get_hurt() -> bool:
	return true

func can_attack() -> bool:
	if Time.get_ticks_msec() - time_last_attack < duration_between_attacks: return false
	return super.can_attack()

# vulerable 脆弱
func is_vulerable() -> bool:
	return state_is(State.RECOVER)
	
func on_receive_damage(dmg: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	if not is_vulerable():
		knockback_force = direction * knockback_intensity
		return
	set_health(current_health - dmg)
	if current_health == 0:
		set_state(State.FALL)
		height_speed = knockdown_intensity
		velocity = direction * knockdown_intensity
	else:
		velocity = Vector2.ZERO
		set_state(State.HURT)

func on_animation_complete() -> void:
	if state_is(State.HURT):
		set_state(State.RECOVER)
		return
	super.on_animation_complete()
