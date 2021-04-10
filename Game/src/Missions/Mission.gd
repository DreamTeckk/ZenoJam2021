extends Control

class_name Mission

var objectives_id_to_complete := []
var objectives_id_completed := []
var completed := false
var mission_name : String

func setup(mission_name: String, objectives_id: Array, objective_manager) -> void:
	self.mission_name = mission_name
	self.objectives_id_to_complete = objectives_id
	$VBoxContainer/MainMission/MissionTitle.text = mission_name
	self.rect_min_size.y = $VBoxContainer.rect_size.y 
	
