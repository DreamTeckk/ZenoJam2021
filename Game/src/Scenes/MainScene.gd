extends Node

onready var ground := $Map/Ground
onready var pathfinding := $Map/Pathfinding
onready var player := $Map/YSort/Player
onready var mission_manager := $GUI/HUD/Interface/Missions
onready var objective_manager := $Map/Objectives

var difficulty = 5

func _ready() -> void:
	$GUI/HUD/Interface/DifficultyMetter/Level.text = str(difficulty)
	pathfinding.create_navigation_map(ground)
	print_debug($Map/YSort/Ennemies.get_children().size())
		
	mission_manager.setup(objective_manager)
	mission_manager.create_pool(2,2,1)
	
	$Map/YSort/Player.setup(pathfinding, mission_manager, objective_manager)
	
	for ennemy in $Map/YSort/Ennemies.get_children():
		ennemy.setup(pathfinding, player, difficulty)

func _process(delta: float) -> void:
	$GUI/HUD/Interface/DifficultyMetter.value = 100 - ($DifficultyIncreaser.time_left / $DifficultyIncreaser.wait_time) * 100
	
	$GUI/HUD/Interface/VBoxContainer/LifeBar.value = (player.health / player.max_health) * 100
	$GUI/HUD/Interface/VBoxContainer/LifeBar/Label.text = str(player.health) +  " / " + str(player.max_health)

func _on_Player_interact(objective_id: int) -> void:
	mission_manager.check_mission_completion_with_objective_id(objective_id)


func _on_DifficultyIncreaser_timeout() -> void:
	# Increase level of dificulty
	difficulty += 1
	$GUI/HUD/Interface/DifficultyMetter/Level.text = str(difficulty)
	for ennemy in $Map/YSort/Ennemies.get_children():
		ennemy.upgrade(difficulty)
	pass
