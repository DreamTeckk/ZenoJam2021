extends Control

class_name Mission

var objectives_id_to_complete := []
var objectives_id_completed := []
var completed := false
var mission_name : String
var objective_manager
export(String) var objective_ui_scene_path

func setup(mission_name: String, objectives_id: Array, objective_manager) -> void:
	self.mission_name = mission_name
	self.objectives_id_to_complete = objectives_id
	self.objective_manager = objective_manager
	$VBoxContainer/MainMission/MissionTitle.text = mission_name
	self.rect_size.y = 38
	
	for i in objectives_id_to_complete.size():
		var objective_ui_scene = load(objective_ui_scene_path).instance()
		$VBoxContainer.add_child(objective_ui_scene)
		self.rect_size.y += $VBoxContainer.get_child(i + 1).rect_size.y
		objective_ui_scene.get_node("Label").text = "Objective " + str(objectives_id_to_complete[i])
		
		var objective : Objective = objective_manager.get_objective_by_id(objectives_id_to_complete[i])
		objective.is_part_of_mission = true
		
	self.rect_min_size.y = self.rect_size.y

	
func completed_objective(id: int) -> void:
	if not objectives_id_completed.has(id):
		var index = objectives_id_to_complete.find(id)
		var objective : Objective = objective_manager.get_objective_by_id(id)
		objective.is_part_of_mission = false
		objectives_id_completed.append(id)
		var cb : CheckBox = $VBoxContainer.get_child(index + 1).get_node("CheckBox")
		cb.pressed = true
		if objectives_id_completed.size() >= objectives_id_to_complete.size():
			$VBoxContainer/MainMission/CheckBox.pressed = true
			completed = true


func erase() -> void:
	self.queue_free()
