extends Node

onready var ground := $Map/Ground
onready var pathfinding := $Map/Pathfinding
onready var player := $Map/YSort/Player
onready var mission_manager := $GUI/HUD/Interface/Missions
onready var objective_manager := $Map/Objectives
onready var ennemy_manager := $Map/YSort/Ennemies

var difficulty = 1

func _ready() -> void:
	$GUI/HUD/Interface/DifficultyMetter/Level.text = str(difficulty)
	pathfinding.create_navigation_map(ground)
	print_debug(ennemy_manager.get_children().size())
		
	mission_manager.setup(objective_manager)
	mission_manager.create_pool(1,2,1,3)
	
	player.setup(pathfinding, mission_manager, objective_manager)
	mission_manager.player = player
	
	ennemy_manager.setup(pathfinding, player)
	
func _process(delta: float) -> void:
	$GUI/HUD/Interface/DifficultyMetter.value = 100 - ($DifficultyIncreaser.time_left / $DifficultyIncreaser.wait_time) * 100

	$GUI/HUD/Interface/VBoxContainer/LifeBar.max_value = player.max_health
	$GUI/HUD/Interface/VBoxContainer/LifeBar.value = player.health
	$GUI/HUD/Interface/VBoxContainer/LifeBar/Label.text = str(player.health) +  " / " + str(player.max_health)

func _on_Player_interact(objective_id: int) -> void:
	mission_manager.check_mission_completion_with_objective_id(objective_id)


func _on_DifficultyIncreaser_timeout() -> void:
	# Increase level of dificulty
	difficulty += 1
	$GUI/HUD/Interface/DifficultyMetter/Level.text = str(difficulty)
	ennemy_manager.difficulty_level = difficulty
	$DifficultyUpSound.play()
