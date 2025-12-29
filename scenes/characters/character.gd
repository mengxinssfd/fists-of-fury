class_name Character
extends CharacterBody2D

const GRAVITY := 600

## 伤害
@export var damage: int
## 倒地时长
@export var duration_grounded: float
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
@onready var damage_receiver : DamageReceiver = $DamageReceiver

enum State {
	IDLE, 
	WALK,
	ATTACK, 
	TAKEOFF, 
	JUMP, 
	LAND, 
	JUMPKICK, 
	HURT,
	FALL,
	GROUNDED,
}

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
}
var current_health := 0
var height := 0.0
var height_speed := 0.0
var state = State.IDLE
## 倒地开始时间
var time_since_grounded := Time.get_ticks_msec()

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	current_health = max_health

func _process(delta: float) -> void:
	#var s = delta * speed
	#if Input.is_action_pressed("ui_right"):
		#position += Vector2.RIGHT * s
	#if Input.is_action_pressed("ui_left"):
		#position += Vector2.LEFT * s
	#if Input.is_action_pressed("ui_up"):
		#position += Vector2.UP * s
	#if Input.is_action_pressed("ui_down"):
		#position += Vector2.DOWN * s

	handle_input()
	handle_movement()
	handle_animations()
	handle_air_time(delta)
	handle_grounded()
	flip_sprites()
	character_sprite.position = Vector2.UP * height
	collision_shape.disabled = state_is(State.GROUNDED)
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

func handle_grounded() -> void:
	if state_is(State.GROUNDED) and Time.get_ticks_msec() - time_since_grounded > duration_grounded:
		set_state(State.LAND)

# 精灵图翻转
func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	elif velocity.x < 0:
		character_sprite.flip_h = true
		damage_emitter.scale.x = -1

func can_move() -> bool:
	return state_in(State.IDLE,State.WALK)

func can_attack() -> bool:
	return state_in(State.IDLE, State.WALK)

func can_jump() -> bool:
	return state_in(State.IDLE, State.WALK)

func can_jumpkick() -> bool:
	return state_is(State.JUMP)

# takeoff 动画完结时调用
func on_takeoff_complate() -> void:
	set_state(State.JUMP)
	height_speed = jump_intensity

# land 动画完结时调用
func on_land_complate() -> void:
	set_state(State.IDLE)

# 动画完结时调用，在动画界面挂载
func on_animation_complete() -> void:
	set_state(State.IDLE)

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type := DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	if state_is(State.JUMPKICK):
		hit_type = DamageReceiver.HitType.KNOCKDOWN
	receiver.damage_received.emit(damage, direction, hit_type)

func on_receive_damage(dmg: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void :
	current_health = clamp(current_health - dmg, 0, max_health)
	if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
		set_state(State.FALL)
		height_speed = knockdown_intensity
	else:
		set_state(State.HURT)
	velocity = direction * knockback_intensity


func set_state(status: State) -> void:
	state = status
	
func state_is(status: State) -> bool:
	return status == state
	
func state_in(...states: Array) -> bool:
	return states.has(state)
