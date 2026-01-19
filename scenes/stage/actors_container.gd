extends Node2D

const SHOT_PREFAB := preload("res://scenes/props/shot.tscn")
const prefab_map := {
	Collectible.Type.KNIFE: preload("res://scenes/props/knife.tscn"),
	Collectible.Type.GUN: preload("res://scenes/props/gun.tscn"),
	Collectible.Type.FOOD: preload("res://scenes/props/food.tscn"),
}

func _ready() -> void:
	EntityManager.spawn_collectible.connect(on_spawn_collectible.bind())
	EntityManager.spawn_shot.connect(on_spawn_shot.bind())

# 生成可拾取道具
func on_spawn_collectible(
	type: Collectible.Type, 
	initial_state: Collectible.State,
	collectible_global_position: Vector2,
	collectible_direction: Vector2,
	initial_height: float,
	autodestroy: bool,
) -> void:
	var collectible : Collectible = prefab_map[type].instantiate()
	collectible.set_state(initial_state)
	collectible.direction = collectible_direction
	collectible.global_position = collectible_global_position
	collectible.height = initial_height
	collectible.autodestroy = autodestroy
	#add_child(collectible)
	call_deferred("add_child", collectible)

func on_spawn_shot(
	gun_root_position: Vector2,
	distance_traveled: float,
	height: float,
) -> void:
	var shot: Shot = SHOT_PREFAB.instantiate()
	add_child(shot)
	shot.initialize(distance_traveled, height)
	shot.position = gun_root_position
	# 不能在此 add_child，不然子弹不会消失
	#add_child(shot)
	
