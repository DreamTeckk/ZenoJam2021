extends KinematicBody2D

export(int) var speed := 100
export(int) var max_health := 20
export(int) var damage := 5
export(float) var attack_cooldown := 1.0 

export(int) var speed_per_level := 25
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
	move()

func setup(pathfinding: Pathfinding, player: Player, difficulty_level: int) -> void:
	self.pathfinding = pathfinding
	self.player = player
	
	speed += speed_per_level * difficulty_level
	max_health += max_health_per_level * difficulty_level
	damage += damage_per_level * difficulty_level
	attack_cooldown += attack_cooldown_per_level * difficulty_level 
	
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
		body.queue_free()
		$HealthBar.update_health(max_health, health)
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

func upgrade(difficulty_level: int) -> void:
	speed = speed_per_level * difficulty_level + speed / difficulty_level 
	max_health = max_health_per_level * difficulty_level + max_health / difficulty_level
	damage = damage_per_level * difficulty_level + damage / difficulty_level
	attack_cooldown -= attack_cooldown_per_level * difficulty_level
	
	$HealthBar.update_health(max_health, health)
