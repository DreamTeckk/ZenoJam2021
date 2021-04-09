extends Control

var bar_width : int

func _ready() -> void:
	bar_width = $background.rect_size.x

func update_health(max_health: int, health: int) -> void:
	var new_width := (clamp(health, 1, INF) / max_health) * bar_width
	$foreground.rect_size.x = new_width
