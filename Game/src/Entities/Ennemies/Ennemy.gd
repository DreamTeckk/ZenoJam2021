extends KinematicBody2D

export(int) var speed := 150
export(int) var max_health := 20
export(int) var damage := 5
export(float) var attack_cooldown := 1.0 

export(int) var speed_per_level := 15
export(int) var max_health_per_level := 5
export(int) var damage_per_level := 2
export(int) var attack_cooldown_per_level := 0.025

var health := max_health
var velocity := Vector2.ZERO
var can_attack := true

var previous_target := Vector2.ZERO
var pathfinding: Pathfinding
var player: Player
var path_recalculated := false

onready var collision_box := $CollisionArea/CollisionBox
onready var attack_cooldown_timer := $AttackCooldown

var on_player := false

func _ready() -> void:
	set_process(false)
	attack_cooldown_timer.wait_time = attack_cooldown
	$AnimationPlayer.play("Ennemy_Run")
	
func _process(delta: float) -> void:
	call_deferred("move")

func setup(pathfinding: Pathfinding, player: Player, difficulty_level: int, spawn_point: Vector2) -> void:
	self.pathfinding = pathfinding
	self.player = player
	
	global_position = spawn_point
	
	speed += speed_per_level * (difficulty_level - 1)
	max_health += max_health_per_level * (difficulty_level - 1)
	damage += damage_per_level * (difficulty_level - 1)
	attack_cooldown += attack_cooldown_per_level * (difficulty_level - 1) 
	
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	
	set_process(true)
	
func move() -> void:
	var path = pathfinding.get_new_path(global_position, player.get_node("Foot").global_position)
	path_recalculated = false
	if path.size() > 1:
		velocity = global_position.direction_to(path[1]) * speed
		move_and_slide(velocity)
		if velocity.x < 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false

func _on_CollisionArea_body_entered(body: Node) -> void:
	if body.is_in_group("Projectils"):
		health -= body.damage
		$HealthBar.max_value = max_health
		$HealthBar.value = health
		body.queue_free()
		if health <= 0.0:
			self.queue_free()
	if body is Player:
		on_player = true
		if can_attack:
			can_attack = false
			attack_cooldown_timer.start()


func _on_CollisionArea_body_exited(body: Node) -> void:
	if body is Player:
		attack_cooldown_timer.stop()
		on_player = false


func _on_AttackCooldown_timeout() -> void:
	if on_player:
		attack_cooldown_timer.start()
		player.get_hit(damage)
	can_attack = true

func upgrade() -> void:
	speed += speed_per_level
	max_health = max_health_per_level
	damage = damage_per_level
	attack_cooldown -= attack_cooldown_per_level
	
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	
func switch_off() -> void:
	set_process(false)
	set_physics_process(false)
	print_debug("ennemy off")

