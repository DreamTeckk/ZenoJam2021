extends Node

class_name MissionsManager

var missions_completed := 0
var missions := []
var objectives_manager
onready var mission_ui_scene = load("res://src/HUD/SingleMission.tscn")

func setup(objectives_manager) -> void:
	self.objectives_manager = objectives_manager
	
func check_mission_completion_with_objective_id(id: int) -> void:
	for mission in missions:
		if mission.objectives_id_to_complete.has(id):
			mission.completed_objective(id)

func register_mission() -> void:
	var new_mission : Mission = mission_ui_scene.instance()
	$MissionsContainer/VBoxContainer/MissionsList.add_child(new_mission)
	new_mission.setup("test mission " + str(randi() % 99) + " : ", take_random_objectives(3), objectives_manager)
	missions.append(new_mission)
		
func complete_mission(mission_index: int) -> void:
	pass
	
func take_random_objectives(nbr: int) -> Array:
	var objectives : Array = objectives_manager.objectives_list
	var unavailable_objectives = []
	var available_objectives = []
	var returned_objectives = []
	for obj in objectives:
		for mission in missions:
			if mission.objectives_id_to_complete.has(obj.objective_id):
				unavailable_objectives.append(obj.objective_id)
				
	for obj in objectives:
		if not unavailable_objectives.has(obj.objective_id):
			available_objectives.append(obj.objective_id)
	
	for i in range(clamp(nbr, 1, available_objectives.size())):
		randomize()
		var random = clamp(randi() % available_objectives.size(), 0, available_objectives.size() - 1) 
		returned_objectives.append(available_objectives[random])
		available_objectives.remove(random)
	
	return returned_objectives
