extends Node

onready var ground := $Map/Ground
onready var pathfinding := $Map/Pathfinding
onready var player := $Map/YSort/Player
onready var mission_manager := $GUI/HUD/Interface/Missions
onready var objective_manager := $Map/Objectives
onready var ennemy_manager := $Map/YSort/Ennemies

var music := true

var difficulty = 1

func _ready() -> void:
	$GUI/HUD/Interface/DifficultyMetter/Level.text = str(difficulty)
	$DeathScreen/Fadein.hide()
	$DeathScreen/DeathMenu.hide()
	$GUI/SoundControl/Barre.hide()
	$Music.play()
	pathfinding.create_navigation_map(ground)
	print_debug(ennemy_manager.get_children().size())
		
	mission_manager.setup(objective_manager)
	mission_manager.create_pool(1,2,1,3)
	
	player.setup(pathfinding, mission_manager, objective_manager)
	mission_manager.player = player
	
	ennemy_manager.setup(pathfinding, player)
	
func _process(delta: float) -> void:
	$GUI/HUD/Interface/DifficultyMetter.value = 100 - ($DifficultyIncreaser.time_left / $DifficultyIncreaser.wait_time) * 100

	$GUI/HUD/Interface/VBoxContainer/LifeBar.max_value = player.max_health
	$GUI/HUD/Interface/VBoxContainer/LifeBar.value = player.health
	$GUI/HUD/Interface/VBoxContainer/LifeBar/Label.text = str(player.health) +  " / " + str(player.max_health)
	
	if player._dead:
		$AfterDeathTimer.start()
		ennemy_manager.switch_off()
		set_process(false)
		$Music.pitch_scale = 0.8

func _on_Player_interact(objective_id: int) -> void:
	mission_manager.check_mission_completion_with_objective_id(objective_id)


func _on_DifficultyIncreaser_timeout() -> void:
	# Increase level of dificulty
	difficulty += 1
	$GUI/HUD/Interface/DifficultyMetter/Level.text = str(difficulty)
	ennemy_manager.difficulty_level = difficulty
	$DifficultyUpSound.play()


func _on_AfterDeathTimer_timeout() -> void:
	$GUI/HUD/Interface.hide()
	$DeathScreen/Fadein.show()
	$DeathScreen/Fadein/FadeinAnimation.play("Fadein")


func _on_FadeinAnimation_animation_finished(anim_name: String) -> void:
	$DeathScreen/DeathMenu/HBoxContainer3/Control/RetryButton.mouse_filter = Control.MOUSE_FILTER_STOP
	$DeathScreen/DeathMenu/HBoxContainer4/Control/MenuButton.mouse_filter = Control.MOUSE_FILTER_STOP
	$DeathScreen/DeathMenu.show()
	$DeathScreen/DeathMenu/HBoxContainer2/Score/VBoxContainer/Control/Score2.text = str(mission_manager.missions_completed)


func _on_RetryButton_pressed() -> void:
	get_tree().reload_current_scene()


func _on_MenuButton_pressed() -> void:
	get_tree().change_scene("res://src/Scenes/MenuScene.tscn")


func _on_AudioStreamPlayer_finished() -> void:
	if music:
		$Music.play()


func _on_SwitchSound_pressed() -> void:
	print_debug($Music.playing)
	if $Music.playing:
		music = false
		$Music.stop()
		$GUI/SoundControl/Barre.show()		
	else:
		music = true
		$Music.play()
		$GUI/SoundControl/Barre.hide()
