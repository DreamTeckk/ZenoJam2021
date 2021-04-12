extends VBoxContainer

class_name Mission

var objectives_id_to_complete := []
var objectives_id_completed := []
var completed := false
var mission_name : String
var objective_manager
export(String) var objective_ui_scene_path

onready var objectives_names := get_node("res://src/Utils/ObjectifNames.gd")

func setup(mission_name: String, objectives_id: Array, objective_manager) -> void:
	self.mission_name = mission_name
	self.objectives_id_to_complete = objectives_id
	self.objective_manager = objective_manager
	$MainMission/MissionTitle.text = mission_name
	
	for i in objectives_id_to_complete.size():
		var objective_ui_scene = load(objective_ui_scene_path).instance()
		add_child(objective_ui_scene)
		objective_ui_scene.get_node("Label").text = generate_name()
		
		var objective : Objective = objective_manager.get_objective_by_id(objectives_id_to_complete[i])
		objective.is_part_of_mission = true

	
func completed_objective(id: int) -> void:
	if not objectives_id_completed.has(id):
		var index = objectives_id_to_complete.find(id)
		var objective : Objective = objective_manager.get_objective_by_id(id)
		objective.is_part_of_mission = false
		objectives_id_completed.append(id)
		var cb : CheckBox = get_child(index + 1).get_node("CheckBox")
		cb.pressed = true
		if objectives_id_completed.size() >= objectives_id_to_complete.size():
			$MainMission/CheckBox.pressed = true
			completed = true

func generate_name() -> String:
	var name = ""
	name += actions[randi() % actions.size()] + " the " 
	randomize()
	if randi() % 2 > 0:
		# Name will have adjective
		name += adjectives[randi() % adjectives.size()].to_lower() + " " 
	randomize()
	name += machines[randi() % machines.size()]

	return name


func erase() -> void:
	self.queue_free()


var actions := [
	"Ajust",
	"Upgrade",
	"Analyze",
	"Examine",
	"Reduce the flow of",
	"Increase the flow of",
	"Order",
	"Restart",
	"Start",
	"Reboot",
	"Slow down",
	"Speed up",
	"Turn on",
	"Turn off",
	"Redirect the data of",
	"Redirect the flow of",
	"Balance",
	"Balance the flow of",
	"Balance the values of",
	"Recalibrate",
	"Activate",
	"Deactivate",
	"Regulate",
	"Test",
	"Empty",
	"Fill",
	"Maneuver",
	"Repare"
]

var adjectives := [
	"Big",
	"Enormous",
	"Huge",
	"Small",
	"Little",
	"Heavy",
	"Light",
	"Central",
	"Turbo",
	"Electric",
	"Charcoal powered",
	"Nuclear powered",
	"Electricity powered",
	"Old",
	"New",
	"Talking",
	"Walking",
	"Out of service",
	"Electro",
	"Mega",
	"Super",
	"Dangerous",
	"Invisible",
	"Unbreakable",
	"Fragile",
]

var machines = [
	"Coal generator",
	"Wind generator",
	"Water generator",
	"Lava generator",
	"Generator generator",
	"Electricity generator",
	"Coal creator",
	"Wind creator",
	"Water creator",
	"Lava creator",
	"Generator creator",
	"Electricity creator",
	"Power plant",
	"Emergency system",
	"Constructor",
	"Assembler",
	"Reactor",
	"Burner",
	"Foundry",
	"Shield",
	"Energy Shield",
	"Shield generator",
	"Main door",
	"Dron Port",
	"Defense system",
	"Manufacturer",
	"Auto-Miner",
	"Laser-Beam"
]
