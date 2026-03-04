extends Node

## 敌人死亡
signal death_enemy(enemy: Character)
## 生成道具-从场景中读取再重新代码生成
signal orphan_actor(orphan: Node2D)
## 生成可拾取道具
signal spawn_collectible(
	type: Collectible.Type,
	initial_state: Collectible.State,
	collectible_global_position: Vector2,
	collectible_direction: Vector2,
	initial_height: float,
	autodestroy: bool,
)
## 生成子弹
signal spawn_shot(
	## 坐标
	gun_root_position: Vector2,
	## 飞行距离
	distance_traveled: float,
	## 飞行高度
	height: float,
)
## 生成敌人
#signal spawn_enemy(enemy_data: EnemyData, player: Player)
signal spawn_enemy(enemy_data: EnemyData)
signal spawn_spark(spark_position: Vector2)
