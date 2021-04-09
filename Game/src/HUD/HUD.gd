extends Control


func _on_Player_take_hit(health_points) -> void:
	$Label.text = str(health_points)
