extends Node2D

func _ready() -> void:
	$EnnemyPathUpdateTimer.connect("timeout", self, "on_ennemy_path_update_Timer_timeout")
	$EnnemyPathUpdateTimer.start()
	
func on_ennemy_path_update_Timer_timeout() -> void:
	for ennemy in $Map/YSort/Ennemies.get_children():
		ennemy._update_path($Map/Navigation2D, $Map/YSort/Player.global_position)
