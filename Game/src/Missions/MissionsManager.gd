extends PanelContainer

class_name MissionsManager

var missions_completed := 0
var missions_total := 0
var mission_to_complete := 0
var mission_pool_completed := 0
var missions_pool := []
var objectives_manager
var player: Player setget set_player
onready var mission_ui_scene = load("res://src/HUD/SingleMission.tscn")

func _process(delta: float) -> void:
	self.rect_min_size.y = 0
	self.rect_size.y = 0

func setup(objectives_manager) -> void:
	self.objectives_manager = objectives_manager
	
func check_mission_completion_with_objective_id(id: int) -> void:
	for mission in missions_pool:
		if !mission.completed and mission.objectives_id_to_complete.has(id) and not mission.objectives_id_completed.has(id):
			mission.completed_objective(id)
			objectives_manager.interact_success()
			if mission.objectives_id_completed.size() >= mission.objectives_id_to_complete.size():
				missions_completed += 1
				mission_pool_completed += 1
				$VBoxContainer/Label.text = "Missions (" + str(missions_completed) + "/" + str(missions_total) + ") :"				
				if mission_pool_completed >= mission_to_complete:
					complete_pool()

func register_mission(obj_nbr: int, index: int) -> Mission:
	var new_objectives = take_random_objectives(obj_nbr)
	if new_objectives.size() <= 0:
		return null 
	var new_mission : Mission = mission_ui_scene.instance()
	$VBoxContainer/MissionsList.add_child(new_mission)
	new_mission.setup("Mission n° " + str(missions_completed + index) + " : ", new_objectives, objectives_manager)
	return new_mission
	
func create_pool(min_nbr: int, max_nbr: int, obj_nbr_min: int, obj_nbr_max: int) -> void:
	randomize()
	var nbr := 0
	var obj_nbr := 0
	
	if min_nbr == max_nbr:
		nbr = min_nbr
	else:
		nbr = randi() % max_nbr + min_nbr
		
	if obj_nbr_min == obj_nbr_max:
		obj_nbr = obj_nbr_min
	else:
		obj_nbr = randi() % obj_nbr_max + obj_nbr_min
	
	
	missions_pool = []
	var missions_added = 0
	for i in range(nbr):
		var new_mission = register_mission(obj_nbr, i+1)
		if new_mission == null:
			continue
		missions_added += 1
		missions_pool.append(new_mission)
	missions_total += missions_added
	mission_to_complete = missions_added
	mission_pool_completed = 0
	$VBoxContainer/Label.text = "Missions (" + str(missions_completed) + "/" + str(missions_total) + ") :"
	
func complete_pool() -> void:
	for mission in missions_pool:
		mission.erase()
	if player:
		player.upgrade_random_skill()
	
	randomize()
	if randi() % 2:
		create_pool(1,2,1,3)
	else:
		create_pool(2,3,1,2)
		


func take_random_objectives(nbr: int) -> Array:
	var objectives : Array = objectives_manager.objectives_list
	var unavailable_objectives = []
	var available_objectives = []
	var returned_objectives = []
	for obj in objectives:
		for mission in missions_pool:
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

func set_player(value: Player) -> void:
	player = value
