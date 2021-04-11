extends StaticBody2D
class_name Objective

var on_wall
var orientation := 0# 0=>N;1=>E;2=>S;3=>W 
var objective_name : String
var objective_id : int
var objective_has_timer: bool
var objective_has_minigame: bool
var objective_scene_path: String
var gorup_color: Color

var activable := false
var is_part_of_mission := false setget set_is_part_of_mission

func setup(id: int, on_wall: bool, orientation: int, objective) -> void:
	self.on_wall = on_wall
	self.orientation = orientation
	
	self.objective_id = id
	self.objective_name = objective.get("Name")
	self.objective_has_timer = objective.get("Has_timer")
	self.objective_has_minigame = objective.get("Has_minigame")
	self.objective_scene_path = objective.get("Scene_path")
	set_is_part_of_mission(false)
	$AnimationPlayer.play("Objective_Light_Wave")
#
#	$DetectionRing.modulate.a = 0.2
	if orientation == 1: 
		$Activable.rotation = deg2rad(90)
	elif orientation == 2: 
		$Activable.rotation = deg2rad(180)
	elif orientation == 3: 
		$Activable.rotation = deg2rad(270)
	

func _on_ActivationArea_body_entered(body: Node) -> void:
	if body.name == "Player":
		activable = true
#		$DetectionRing.modulate.a = 1
		body._interactable = self


func _on_ActivationArea_body_exited(body: Node) -> void:
	if body.name == "Player":
		activable = false
#		$DetectionRing.modulate.a = 0.2
		body._interactable = null
		
func set_is_part_of_mission(value: bool) -> void:
	is_part_of_mission = value
	if is_part_of_mission:
		$Light2D.show()
	else:
		$Light2D.hide()

