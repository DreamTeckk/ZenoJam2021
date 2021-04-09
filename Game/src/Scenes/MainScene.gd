extends Node2D

onready var _thread := Thread.new()
onready var ground := $Map/Ground
onready var pathfinding := $Map/Pathfinding
onready var player := $Map/YSort/Player

func _ready() -> void:
	
	pathfinding.create_navigation_map(ground)
	print_debug($Map/YSort/Ennemies.get_children().size())
	for ennemy in $Map/YSort/Ennemies.get_children():
		ennemy.setup(pathfinding, player)

func _on_EnnemyPathUpdateTimer_timeout() -> void:
	for ennemy in $Map/YSort/Ennemies.get_children():
#		ennemy.pathfinding.update_navigation_map()
		pass
