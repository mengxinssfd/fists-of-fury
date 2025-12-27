extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

#var animation_player
#func _ready() -> void:
	#animation_player = get_node("AnimationPlayer")
	
@onready var animation_player := $AnimationPlayer 
@onready var character_sprite := $CharacterSprite

enum State {IDLE, WALK}

var state = State.IDLE

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
	if velocity.length() == 0:
		state = State.IDLE
	else:
		state = State.WALK
		
func handle_input() -> void:
	var direction := Input.get_vector('ui_left', 'ui_right','ui_up','ui_down')
	#position += direction * delta * speed
	velocity = direction* speed
	
func handle_animations() -> void:
	if state == State.IDLE:
		animation_player.play("idle")
	elif state == State.WALK:
		animation_player.play("walk")

func flip_sprites() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0: 
		character_sprite.flip_h = true
