extends Control

class_name Mission

var objectives_id_to_complete := []
var objectives_id_completed := []
var completed := false
var mission_name : String
var base_height
export(String) var objective_ui_scene_path

func setup(mission_name: String, objectives_id: Array, objective_manager) -> void:
	self.mission_name = mission_name
	self.objectives_id_to_complete = objectives_id
	$VBoxContainer/MainMission/MissionTitle.text = mission_name
	self.rect_min_size.y = $VBoxContainer.rect_size.y
	base_height = self.rect_min_size.y
	
	for i in objectives_id_to_complete:
		var objective_ui_scene = load(objective_ui_scene_path).instance()
		$VBoxContainer.add_child(objective_ui_scene)
		objective_ui_scene.get_node("Label").text = "Objective " + str(i)
		self.rect_min_size.y += objective_ui_scene.rect_size.y 

func completed_objective(id: int) -> void:
	var index = objectives_id_to_complete.find(id)
	objectives_id_completed.append(id)
	var cb : CheckBox = $VBoxContainer.get_child(index + 1).get_node("CheckBox")
	cb.pressed = true
	if objectives_id_completed.size() >= objectives_id_to_complete.size():
		$VBoxContainer/MainMission/CheckBox.pressed = true
