class_name Character
extends CharacterBody2D

const GRAVITY := 600

## 允许复活
@export var can_respawn : bool
## 可重新生成飞刀
@export var can_respawn_knives : bool
## 重新生成飞刀的等待时间
@export var duration_between_knife_respawn : int
## 伤害
@export var damage: int
## 重拳伤害
@export var damage_power: int
## 倒地时长
@export var duration_grounded: float
## 被强力攻击击中时飞行的速度
@export var flight_speed: float
## 是否持刀
@export var has_knife: bool
## 最大生命
@export var max_health: int
## 跳跃强度
@export var jump_intensity :float
## 击退强度
@export var knockback_intensity :float
## 击倒强度
@export var knockdown_intensity :float
## 行走速度
@export var speed: float

#var animation_player
#func _ready() -> void:
	#animation_player = get_node("AnimationPlayer")

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var collision_shape := $CollisionShape2D
@onready var damage_emitter := $DamageEmitter
@onready var collateral_emitter := $CollateralDamageEmitter
@onready var damage_receiver : DamageReceiver = $DamageReceiver
@onready var knife_sprite := $KnifeSprite
@onready var projectile_aim :RayCast2D = $ProjectileAim
@onready var collectible_sensor: Area2D = $CollectibleSensor

enum State {
	IDLE,
	WALK,
	## 地面普通攻击
	ATTACK,
	## 跳跃时起跳
	TAKEOFF,
	## 跳跃中
	JUMP,
	## 跳跃时落地
	LAND,
	## 跳跃时攻击
	JUMPKICK,
	## 被普通攻击
	HURT,
	## 击飞时掉落
	FALL,
	## 躺地上
	GROUNDED,
	DEATH,
	## 被强力攻击击飞
	FLY,
	## 准备攻击，敌人才有的
	PREP_ATTACK,
	## 投掷
	THROW,
	## 拾取
	PICKUP,
}

var anim_attacks := []
# 状态对应动画
var anim_map := {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt",
	State.FALL: "fall",
	State.GROUNDED: "grounded",
	State.DEATH: "grounded",
	State.FLY: "fly",
	State.PREP_ATTACK: "idle",
	State.THROW: "throw",
	State.PICKUP: "pickup",
}
var attack_combo_index := 0
var current_health := 0
## 头朝向
var heading := Vector2.RIGHT
var height := 0.0
var height_speed := 0.0
var is_last_hit_successful := false
var state = State.IDLE
## 倒地开始时间
var time_since_grounded := Time.get_ticks_msec()
## 上次丢失飞刀时间
var time_since_knife_dismiss := Time.get_ticks_msec()

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	collateral_emitter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_emitter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	handle_prep_attack()
	handle_grounded()
	handle_knife_respawns()
	handle_death(delta)
	set_handing()
	flip_sprites()
	knife_sprite.visible = has_knife
	var h = Vector2.UP * height
	character_sprite.position = h
	knife_sprite.position = h
	collision_shape.disabled = is_collision_disalbed()
	# damage_receiver.monitorable = can_get_hurt()
	move_and_slide()

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			set_state(State.IDLE)
		else:
			set_state(State.WALK)
	#else:
		#velocity = Vector2.ZERO

func handle_input() -> void:
	pass

func handle_animations() -> void:
	var aa = anim_attacks[attack_combo_index]
	if state_is(State.ATTACK) and animation_player.has_animation(aa):
		animation_player.play(aa)
		return
	var ani = anim_map[state]
	if animation_player.has_animation(ani):
		animation_player.play(ani)

func handle_air_time(delta: float) -> void:
	if state_in(State.JUMP, State.JUMPKICK, State.FALL):
		height += height_speed * delta
		if height < 0:
			height = 0
			if state_is(State.FALL):
				set_state(State.GROUNDED)
				time_since_grounded = Time.get_ticks_msec()
			else:
				set_state(State.LAND)
			velocity = Vector2.ZERO
		else:
			height_speed -= GRAVITY * delta

func handle_prep_attack() -> void:
	pass

func handle_grounded() -> void:
	if state_is(State.GROUNDED) and Time.get_ticks_msec() - time_since_grounded > duration_grounded:
		set_state(State.DEATH if current_health == 0 else State.LAND)

func handle_knife_respawns() -> void:
	if (
		can_respawn_knives and not has_knife and
		Time.get_ticks_msec() - time_since_knife_dismiss > duration_between_knife_respawn
	):
		has_knife = true

func handle_death(delta: float) -> void:
	if state_is(State.DEATH) and not can_respawn:
		modulate.a -= delta / 2.0
		if modulate.a <= 0:
			queue_free()

func set_handing() -> void:
	pass

# 精灵图翻转
func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		knife_sprite.flip_h = false
		damage_emitter.scale.x = 1
		projectile_aim.scale.x = 1
	else:
		character_sprite.flip_h = true
		knife_sprite.flip_h = true
		damage_emitter.scale.x = -1
		projectile_aim.scale.x = -1

func can_move() -> bool:
	return state_in(State.IDLE,State.WALK)

func can_attack() -> bool:
	return state_in(State.IDLE, State.WALK)

func can_jump() -> bool:
	return state_in(State.IDLE, State.WALK)

func can_jumpkick() -> bool:
	return state_is(State.JUMP)

func can_get_hurt() -> bool:
	return state_in(
		State.IDLE,
		State.WALK,
		State.TAKEOFF,
		#State.JUMP,
		State.LAND,
		State.PREP_ATTACK
	)

func can_pickup_collectible(collectible := get_collectible()) -> bool:
	if not collectible: return false
	if (
		collectible.type == Collectible.Type.KNIFE
		and not has_knife
	):
		return true
	return false

func get_collectible() -> Collectible:
	var collectible_areas := collectible_sensor.get_overlapping_areas()
	if collectible_areas.size() == 0:
		return null
	var collectible : Collectible = collectible_areas[0]
	return collectible

func pickup_collectible() -> void:
	var collectible := get_collectible()
	if can_pickup_collectible(collectible):
		has_knife = true
		collectible.queue_free()


func is_collision_disalbed() -> bool:
	return state_in(
		State.GROUNDED,
		State.DEATH,
		State.FLY
	)

# takeoff 动画完结时调用
func on_takeoff_complete() -> void:
	set_state(State.JUMP)
	height_speed = jump_intensity

func on_pickup_complete() -> void:
	set_state(State.IDLE)
	pickup_collectible()

# land 动画完结时调用
func on_land_complete() -> void:
	set_state(State.IDLE)

# 动画完结时调用，在动画界面挂载
func on_animation_complete() -> void:
	set_state(State.IDLE)

func on_throw_complete() -> void:
	set_state(State.IDLE)
	has_knife = false

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type := DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var current_damage = damage
	if state_is(State.JUMPKICK):
		hit_type = DamageReceiver.HitType.KNOCKDOWN
		is_last_hit_successful = false
	else:
		is_last_hit_successful = true
		if attack_combo_index == anim_attacks.size() - 1:
			hit_type = DamageReceiver.HitType.POWER
			current_damage = damage_power
	receiver.damage_received.emit(current_damage, direction, hit_type)


func on_emit_collateral_damage(receiver: DamageReceiver) -> void:
	if receiver != damage_receiver:
		var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(0, direction, DamageReceiver.HitType.KNOCKDOWN)

func on_wall_hit	(_wall: AnimatableBody2D) -> void:
	set_state(State.FALL)
	height_speed = knockback_intensity
	velocity = -velocity / 2.0

func on_receive_damage(dmg: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void :
	if not can_get_hurt():
		return
	if has_knife:
		has_knife = false
		time_since_knife_dismiss = Time.get_ticks_msec()
	current_health = clamp(current_health - dmg, 0, max_health)
	if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
		set_state(State.FALL)
		height_speed = knockdown_intensity
		velocity = direction * knockback_intensity
	elif hit_type == DamageReceiver.HitType.POWER:
		set_state(State.FLY)
		velocity = direction * flight_speed
	elif hit_type == DamageReceiver.HitType.NORMAL:
		set_state(State.HURT)
		velocity = direction * knockback_intensity


func set_state(status: State) -> void:
	state = status

func state_is(status: State) -> bool:
	return status == state

func state_in(...states: Array) -> bool:
	return states.has(state)
