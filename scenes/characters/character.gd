extends CharacterBody2D

const GRAVITY := 600

@export var health: int
@export var damage: int
# 跳跃强度
@export var jump_intensity :float
@export var speed: float

#var animation_player
#func _ready() -> void:
	#animation_player = get_node("AnimationPlayer")

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter

enum State {IDLE, WALK, ATTACK, TAKEOFF, JUMP, LAND}

# 状态对应动画
var anim_map := {
	State.IDLE: 'idle',
	State.WALK: 'walk',
	State.ATTACK: 'punch',
	State.TAKEOFF: 'takeoff',
	State.JUMP: 'jump',
	State.LAND: 'land',
}
var height := 0.0
var height_speed := 0.0
var state = State.IDLE

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())

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
	var direction := Input.get_vector('ui_left', 'ui_right','ui_up','ui_down')
	#position += direction * delta * speed
	velocity = direction* speed

	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF

func handle_animations() -> void:
	var ani = anim_map[state]
	if animation_player.has_animation(ani):
		animation_player.play(ani)
	
func handle_air_time(delta: float) -> void:
	if state == State.JUMP:
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

func on_emit_damage(damage_receiver: DamageReceiver) -> void:
	var direction := Vector2.LEFT if damage_receiver.global_position.x < global_position.x else Vector2.RIGHT
	damage_receiver.damage_received.emit(damage, direction)
	print(damage_receiver)
