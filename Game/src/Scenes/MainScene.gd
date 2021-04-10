extends Node

onready var ground := $Map/Ground
onready var pathfinding := $Map/Pathfinding
onready var player := $Map/YSort/Player
onready var mission_manager := $HUD/Interface/Missions
onready var objective_manager := $Map/Objectives

func _ready() -> void:
	
	pathfinding.create_navigation_map(ground)
	print_debug($Map/YSort/Ennemies.get_children().size())
	for ennemy in $Map/YSort/Ennemies.get_children():
		ennemy.setup(pathfinding, player)
		
	mission_manager.setup(objective_manager)
	mission_manager.register_mission()

func _on_Player_interact(objective_id: int) -> void:
	mission_manager.check_mission_completion_with_objective_id(objective_id)
