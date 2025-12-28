extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

#var animation_player
#func _ready() -> void:
	#animation_player = get_node("AnimationPlayer")
	
@onready var animation_player := $AnimationPlayer 
@onready var character_sprite := $CharacterSprite
@onready var damage_emitter := $DamageEmitter

enum State {IDLE, WALK, ATTACK}

var state = State.IDLE

func _ready() -> void:
	damage_emitter.area_entered.connect(on_emit_damage.bind())

func _process(_delta: float) -> void:
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
	flip_sprites()
	move_and_slide()
	
func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = State.IDLE
		else:
			state = State.WALK
	else:
		velocity = Vector2.ZERO
		
func handle_input() -> void:
	var direction := Input.get_vector('ui_left', 'ui_right','ui_up','ui_down')
	#position += direction * delta * speed
	velocity = direction* speed
	
	if can_attack() and Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	
func handle_animations() -> void:
	if state == State.IDLE:
		animation_player.play("idle")
	elif state == State.WALK:
		animation_player.play("walk")
	elif state == State.ATTACK:
		animation_player.play("punch")

# 精灵图翻转
func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0: 
		character_sprite.flip_h = true

func can_move() -> bool:
	return state == State.IDLE or state == State.WALK

func can_attack() -> bool:
	return state == State.IDLE or state == State.WALK
	
# 动画完结时调用，在动画界面挂载
func on_animation_complete() -> void:
	state = State.IDLE

func on_emit_damage(damage_receiver: DamageReceiver) -> void:
	damage_receiver.damage_received.emit(damage)
	print(damage_receiver)
	
