extends KinematicBody2D
class_name Player

var _velocity := Vector2.ZERO
var _dead := false
var _can_shoot := true
var _interactable : Objective = null
var _weapon_direction = Weapon_Direction.EAST
var pathfinding : Pathfinding
var mission_manager
var objective_manager

enum Weapon_Direction {WEST, EAST}

export(float) var max_health := 100.0
export(float) var speed := 300.0
export(float) var health := max_health
export(String) var world_node_name
export(float) var reload_time := 0.1

onready var _projectil_scene = load("res://src/Entities/Weapons/Projectil.tscn")

signal take_hit
signal died
signal interact

func _ready() -> void:
	$ReloadTimer.connect("timeout", self, "_on_reload_timer_timeout")
	set_physics_process(false)
	set_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)

func setup(pathfinding: Pathfinding, mission_manager, objective_manager) -> void:
	self.pathfinding = pathfinding
	self.mission_manager = mission_manager
	self.objective_manager = objective_manager
	
	set_physics_process(true)
	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	
func _physics_process(delta: float) -> void:
	if !_dead:
		_velocity = self.move_and_slide(move().normalized() * speed)
		if Input.is_action_pressed("fire"):
			if _can_shoot:
				_fire()
		if Input.is_action_just_pressed("interacte"): 
			if _interactable != null:
				emit_signal("interact", _interactable.objective_id)
		animate()
	else:
		_die()

func _process(delta: float) -> void:
	update_arrow_direction()

func update_arrow_direction() -> void:
#	var path = pathfinding.get_new_path(global_position, get_nearest_objective())
#	if path.size() > 1:
#		$PathIndicator.look_at(path[1])
	$PathIndicator.look_at(get_nearest_objective())	
	
func get_nearest_objective() -> Vector2:
	var missions = mission_manager.missions_pool
	var nearest_distance = INF
	var nearest_objective_pos: Vector2
	for mission in missions:
		for objective_id in mission.objectives_id_to_complete:
			if mission.objectives_id_completed.has(objective_id):
				continue
			var objective = objective_manager.get_objective_by_id(objective_id)
			var distance = global_position.distance_to(objective.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_objective_pos = objective.global_position 
			
	return nearest_objective_pos

func move() -> Vector2: 
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
func animate() -> void:
	$AnimationPlayer.stop(false)
	if _velocity == Vector2.ZERO:
		$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("Run")
	
	if _weapon_direction == Weapon_Direction.EAST:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

func get_hit(damage: int): 
	if !_dead:
		health = clamp(health - damage, 0, max_health)
		print_debug("Remaining health : " + str(health))
		if health == 0: 
			_dead = true
		emit_signal("take_hit", max_health, health)
	
func _die():
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	print_debug("You died !")
	emit_signal("died")

func _input(event: InputEvent) -> void:
	var direction_aimed: = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		)
	if direction_aimed != Vector2.ZERO:
		$Weapon.rotation = direction_aimed.angle()
		_flip_weapon()
			
func _fire() -> void:
	_can_shoot = false
	
	$AudioStreamPlayer.play()
	$Weapon/MusleFlashAnimation.play("Musle_Flash")
	$ReloadTimer.start(reload_time)
	
	var projectil = _projectil_scene.instance()

	var node_name = ""
	var base_node = self
	var max_test = 10
	var test = 0
	
	# Get the main scene node
	while node_name != world_node_name or test >= max_test:
		base_node = base_node.get_parent()
		node_name = base_node.name
		test += 1
	
	if test >= max_test:
		print_debug("Error : " + world_node_name + " node not found !") 
		return
		
	base_node.add_child(projectil)
	projectil.setup($Weapon/Cannon.global_position, $Weapon.rotation)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		$Weapon.rotation = get_local_mouse_position().angle()
		_flip_weapon()
		
func _flip_weapon() -> void: 
	if $Weapon.rotation > deg2rad(90) or $Weapon.rotation < deg2rad(-90):
		_weapon_direction = Weapon_Direction.WEST
		$Weapon.flip_v = true
	else: 
		_weapon_direction = Weapon_Direction.EAST
		$Weapon.flip_v = false 

func _on_reload_timer_timeout() -> void:
	_can_shoot = true


# Interaction on required objective
func _on_Objectives_interact() -> void:
	$CameraAnimation.play("Camera_Shake")


func _on_UpdateArrow_timeout() -> void:
#	update_arrow_direction()
	pass
