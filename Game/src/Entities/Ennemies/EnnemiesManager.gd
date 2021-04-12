extends Node2D

var pathfinding : Pathfinding
var player : Player
var difficulty_level : int setget set_difficulty
var max_ennemies := 20
var ennemies_respanw_rate := 5.0

var max_ennemies_per_level := 10
var ennemies_respawn_rate_per_level := 0.5

var max_ennemies_cap := 200

var spawn_queu := []

onready var ennemy_scene_path := load("res://src/Entities/Ennemies/Ennemy.tscn")

func setup(pathfinding: Pathfinding, player: Player) -> void:
	self.pathfinding = pathfinding
	self.player = player
	
	$EnnemyRespawnTimer.wait_time = ennemies_respanw_rate
	$EnnemyRespawnTimer.start()

func set_difficulty(value: int) -> void:
	difficulty_level = value
	ennemies_respanw_rate = clamp(ennemies_respanw_rate - ennemies_respawn_rate_per_level, 0.5, 5.0) 
	max_ennemies = clamp(max_ennemies + max_ennemies_per_level, max_ennemies, max_ennemies_cap)
	for ennemy in $EnnemyAgents.get_children():
		ennemy.upgrade()
		
	$EnnemyRespawnTimer.wait_time = ennemies_respanw_rate
	$EnnemyRespawnTimer.start()


func _on_EnnemyRespawnTimer_timeout() -> void:
	if $EnnemyAgents.get_children().size() < max_ennemies:
		var ennemies_to_spawn := max_ennemies - $EnnemyAgents.get_children().size()
		spawn_new_ennemies(get_spawn_points_pool(), ennemies_to_spawn)

func get_spawn_points_pool() -> Array:
	var pool := []
	var spawn_to_push := (max_ennemies - (max_ennemies % 5)) / 5
	for i in range(spawn_to_push):
		randomize()
		var rdm = randi() % $EnnemySpawnPoints.get_children().size()
		pool.append($EnnemySpawnPoints.get_child(rdm))
	return pool

func spawn_new_ennemies(spawn_point_pool: Array, ennemies_to_spawn: int) -> void:
	for i in range(ennemies_to_spawn):
		randomize()
		var rdm_sp_index = randi() % spawn_point_pool.size()
		spawn_queu.append(spawn_point_pool[rdm_sp_index].global_position)

func _on_EnnemySpawnEscapeTimer_timeout() -> void:
	if spawn_queu.size() > 0:
		var ennemy = ennemy_scene_path.instance()
		$EnnemyAgents.add_child(ennemy)
		ennemy.setup(pathfinding, player, difficulty_level, spawn_queu[0])
		spawn_queu.remove(0)
	
