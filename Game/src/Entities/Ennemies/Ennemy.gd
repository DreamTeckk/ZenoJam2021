extends KinematicBody2D

export(float) var speed := 100.0
export(float) var max_health := 50.0
export(float) var damage := 10.0
export(float) var attack_cooldown := 1.0 
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
	
func _process(delta: float) -> void:
	move()

func setup(pathfinding: Pathfinding, player: Player) -> void:
	self.pathfinding = pathfinding
	self.player = player
	set_process(true)
	
func move() -> void:
	var path = pathfinding.get_new_path(global_position, player.get_node("Foot").global_position)
	path_recalculated = false
	if path.size() > 1:
		velocity = global_position.direction_to(path[1]) * speed
		$Sprite.rotation = lerp_angle(rotation, global_position.direction_to(path[1]).angle(), 0.1)
		move_and_slide(velocity)

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
	
