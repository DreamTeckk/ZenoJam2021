extends Node2D

export(int) var max_objectives
export(int) var max_objectives_per_type
export(String) var objective_scene_path

var objective_scene
var objective_spawn_points := []
var spawn_points_used := []
var objectives_list := []

var objectives_dictionary = {
	"Lever": {
		"Name": "Lever",
		"Has_minigame": false,
		"Has_timer": false,
		"Scene_path": "",
		"On_wall": false
	},
	"Control_Panel": {
		"Name": "Control Panel",
		"Has_minigame": false,
		"Has_timer": true,
		"Scene_path": "",
		"On_wall": true
	},
	"Target": {
		"Name": "Target",
		"Has_minigame": false,
		"Has_timer": false,
		"Scene_path": "",
		"On_wall": true
	}, 
}

func _ready() -> void:
	objective_scene = load(objective_scene_path)
	objective_spawn_points = self.get_children()
	
	#Ensure that there are no more objectives than objective spawn points
	max_objectives = clamp(max_objectives, 0, objective_spawn_points.size()) 
	populate_objectives()
	
func populate_objectives() -> void:
	for i in max_objectives:
		
		# Get objectives on wall and not
		var on_wall_objectives = []
		var not_on_wall_objectives = []
		for key in objectives_dictionary.keys():
			if objectives_dictionary.get(key).get('On_wall'):
				on_wall_objectives.append(objectives_dictionary.get(key))
			else:
				not_on_wall_objectives.append(objectives_dictionary.get(key))
		
		randomize()
		var index = randi() % objective_spawn_points.size()
		
		while spawn_points_used.has(index):
			index = randi() % objective_spawn_points.size()
		spawn_points_used.append(index)
		
		var new_objective = objective_scene.instance()
		var spawn = self.get_child(index)
		
		objectives_list.append(new_objective)
		spawn.add_child(new_objective)
		
		var rdm_objective
		var direction = null
		randomize()
		if spawn.on_wall:
			rdm_objective = on_wall_objectives[randi() % on_wall_objectives.size()]
		else:
			rdm_objective = not_on_wall_objectives[randi() % not_on_wall_objectives.size()]
			
		new_objective.setup(i, spawn.on_wall, spawn.orientation, rdm_objective)

func get_objective_by_id(id: int) -> Objective:
	return objectives_list[id]
