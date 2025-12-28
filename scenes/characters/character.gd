class_name Character
extends CharacterBody2D

const GRAVITY := 600

@export var damage: int
@export var max_health: int
# 跳跃强度
@export var jump_intensity :float
@export var knockback_intensity :float
@export var speed: float

#var animation_player
#func _ready() -> void:
	#animation_player = get_node("AnimationPlayer")

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter
@onready var damage_receiver : DamageReceiver = $DamageReceiver

enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND, JUMPKICK, HURT}

# 状态对应动画
var anim_map := {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.ATTACK: "punch",
	State.TAKEOFF: "takeoff",
	State.JUMP: "jump",
	State.LAND: "land",
	State.JUMPKICK: "jumpkick",
	State.HURT: "hurt"
}
var current_health := 0
var height := 0.0
var height_speed := 0.0
var state = State.IDLE

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
	flip_sprites()
	character_sprite.position = Vector2.UP * height
	move_and_slide()

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK
	#else:
		#velocity = Vector2.ZERO

func handle_input() -> void:
	pass

func handle_animations() -> void:
	var ani = anim_map[state]
	if animation_player.has_animation(ani):
		animation_player.play(ani)
	
func handle_air_time(delta: float) -> void:
	if state == State.JUMP or state == State.JUMPKICK:
		height += height_speed * delta
		if height < 0:
			height = 0
			state = State.LAND 
		else:
			height_speed -= GRAVITY * delta

# 精灵图翻转
func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emitter.scale.x = 1
	elif velocity.x < 0:
		character_sprite.flip_h = true
		damage_emitter.scale.x = -1

func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jump() -> bool:
	return state == State.IDLE or state == State.WALK

func can_jumpkick() -> bool:
	return state == State.JUMP

# takeoff 动画完结时调用
func on_takeoff_complate() -> void:
	state = State.JUMP
	height_speed = jump_intensity

# land 动画完结时调用
func on_land_complate() -> void:
	state = State.IDLE

# 动画完结时调用，在动画界面挂载
func on_animation_complete() -> void:
	state = State.IDLE

func on_emit_damage(receiver: DamageReceiver) -> void:
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	receiver.damage_received.emit(damage, direction)

func on_receive_damage(dmg: int, direction: Vector2) -> void :
	current_health = clamp(current_health - dmg, 0, max_health)
	if current_health <= 0:
		queue_free()
	else:
		state = State.HURT
		velocity = direction * knockback_intensity
