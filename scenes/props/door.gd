class_name Door extends Node2D

signal opened
signal open_door

## 门开启所需时间，单位ms
@export var duration_open: float

@onready var sprite: Sprite2D = $DoorSprite
# duration_open 是export属性，不加onready的话，编辑器设置的值要延迟才能获取到
@onready var time_opening := DurationTool.new(duration_open)
# 文件内的@onready变量是有顺序的，door_height就不能放置到sprite前，否则会报错
@onready var door_height := sprite.texture.get_height()

enum State { CLOSED, OPENING, OPENED }

var state := State.CLOSED

func _ready() -> void:
	open_door.connect(open.bind)

func _process(_delta: float) -> void:
	if state == State.OPENING:
		var p := Vector2.UP * door_height
		if time_opening.is_over_duration():
			state = State.OPENED
			sprite.position = p
			opened.emit()
		else:
			var progress := time_opening.get_progress()
			sprite.position = lerp(Vector2.ZERO, p, progress)

func open() -> void:
	if state == State.CLOSED:
		state = State.OPENING
		time_opening.refresh()
