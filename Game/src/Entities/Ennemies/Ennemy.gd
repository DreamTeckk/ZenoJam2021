extends KinematicBody2D

export var _speed := 100.0
export var max_health := 50.0
var health := max_health

var previous_target := Vector2.ZERO
var path := PoolVector2Array() setget set_path

func _ready() -> void:
	set_process(false)
	
func _process(delta: float) -> void:
	var move_distance := _speed * delta
	move(move_distance) 

func _update_path(nav2D: Navigation2D, player_position: Vector2) -> void:
	if previous_target != player_position:
		previous_target = player_position
		var new_path := nav2D.get_simple_path(self.global_position, player_position)
		self.path = new_path
	
func move(distance: float) -> void:
	var start_point := self.position
	for i in range(path.size()):
		var distance_to_next := start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif path.size() == 1 && distance > distance_to_next:
			position = path[0]
			set_process(false)
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func set_path(value: PoolVector2Array) -> void:
	path = value
	if value.size() == 0:
		return
	set_process(true)


func _on_ProjectilArea_body_entered(body: Node) -> void:
	if body.is_in_group("Projectils"):
		health -= body.damage
		$HealthBar.update_health(max_health, health)
		if health <= 0.0:
			self.queue_free()
