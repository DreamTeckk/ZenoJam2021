extends CanvasLayer


func _on_TextureButton_pressed() -> void:
	get_tree().change_scene("res://src/Scenes/MenuScene.tscn")
