extends CanvasLayer

onready var main_scene := "res://src/Scenes/MainScene.tscn"
onready var tutorial_scene := "res://src/Scenes/TutorialScene.tscn"


func _ready() -> void:
	$Fadein.hide()


func _on_PlayButton_pressed() -> void:
	$Fadein.show()
	$Fadein/AnimationPlayer.play("Fadein")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	get_tree().change_scene(main_scene)


func _on_TutorialButton_pressed() -> void:
	get_tree().change_scene(tutorial_scene)
