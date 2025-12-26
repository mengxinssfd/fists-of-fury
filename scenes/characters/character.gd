extends CharacterBody2D

@export var health: int
@export var damage: int
@export var speed: float

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
		
	var direction := Input.get_vector('ui_left', 'ui_right','ui_up','ui_down')
	#position += direction * delta * speed
	velocity = direction* speed
	move_and_slide()
