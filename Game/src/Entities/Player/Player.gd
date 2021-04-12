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
var can_heal := true

enum Upgrade_Skill {MAX_HEALTH, SPEED, DAMAGE, PROJ_SPEED, RELOAD_TIME, HEAL_RATE, HEAL_SPEED}

enum Weapon_Direction {WEST, EAST}

export(int) var max_health := 100
export(int) var speed := 300
export(int) var health := max_health
export(int) var damage := 5
export(float) var projectil_speed := 400
export(String) var world_node_name
export(float) var reload_time := 1.5
export(int) var healing_rate := 2
export(float) var healing_speed := 2

var healing_speed_cap := 0.2
var projectil_speed_cap := 2000
var reload_time_cap := 0.05

var max_health_per_level := 20
var speed_per_level := 25
var damage_per_level := 5
var projectil_speed_per_level := 50
var reload_time_per_level := 0.1
var healing_rate_per_level := 4
var healing_speed_per_level := 0.2

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
		if _velocity != Vector2.ZERO and !$RunSound.playing:
			$RunSound.play()
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
		$HealingTimer.stop()
		$RecoverTimer.stop()
		$RecoverTimer.start()
		health = clamp(health - damage, 0, max_health)
		if health == 0: 
			_dead = true


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
			
	if event is InputEventMouse:
		$Weapon.rotation = get_local_mouse_position().angle()
		_flip_weapon()
	
func _fire() -> void:
	_can_shoot = false
	
	$WeaponShootSound.play()
	$WeaponAnimation.play("Weapon_Shoot")
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
	projectil.setup($Weapon/Cannon.global_position, $Weapon.rotation, damage, projectil_speed)


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
	$InteractSound.play()
	$CameraAnimation.play("Camera_Shake")


func _on_RecoverTimer_timeout() -> void:
	$HealingTimer.start(healing_speed)

func _on_HealingTimer_timeout() -> void:
	health = clamp(health + healing_rate, 0, max_health)

func upgrade_random_skill() -> void:
	randomize()
	var random_skill := randi() % Upgrade_Skill.size()
	var text : String
	match random_skill:
		Upgrade_Skill.DAMAGE:
			damage += damage_per_level
			text = "Damages : +" + str(damage_per_level)
		Upgrade_Skill.HEAL_RATE:
			healing_rate += healing_rate_per_level
			text = "Healing Rate : +" + str(healing_rate_per_level)
		Upgrade_Skill.HEAL_SPEED:
			if healing_speed <= healing_speed_cap:
				upgrade_random_skill()
			else:
				healing_speed = clamp(healing_speed - healing_speed_per_level, healing_speed_cap, INF)
				text = "Healing Speed : heal every " + str(clamp(healing_speed - healing_speed_per_level, healing_speed_cap, INF)) + "sec"
		Upgrade_Skill.MAX_HEALTH:
			print_debug("Upgrade MAX HEALTH")
			if health == max_health:
				health = max_health + max_health_per_level
			max_health += max_health_per_level
			text = "Max Health : +" + str(max_health_per_level) + "hp"
		Upgrade_Skill.PROJ_SPEED:
			if projectil_speed >= projectil_speed_cap:
				upgrade_random_skill()
			else:
				projectil_speed = clamp(projectil_speed + projectil_speed_per_level, 0, projectil_speed_cap)
				text = "Bullet Speed : +" + str(projectil_speed_per_level)
		Upgrade_Skill.RELOAD_TIME:
			if reload_time <= reload_time_cap:
				upgrade_random_skill()
			else:
				reload_time = clamp(reload_time - reload_time_per_level, reload_time_cap, INF) 
				text = "Reload Time : -" + str(reload_time_per_level) + "sec"
		Upgrade_Skill.SPEED:
			speed += speed_per_level
			text = "Speed : +" + str(speed_per_level)
	
	$MissionsCompletedSound.play()
	$Upgrade.text = text
	$MissionCompleted/Animation.stop()
	$MissionCompleted/Animation.play("Missions_Completed")
	
	$Upgrade/Animation.stop()
	$Upgrade/Animation.play("Upgrade")
