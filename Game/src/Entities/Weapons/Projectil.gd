extends KinematicBody2D

var _direction_angle := 0.0
var damage := 10.0
export(int) var speed := 400

func _ready() -> void:
	self.set_physics_process(false)

func _physics_process(delta: float) -> void:
	self.transform.origin += (Vector2(cos(_direction_angle), sin(_direction_angle)).normalized() * speed * delta)
	
func setup(origin: Vector2, fire_angle: float) -> void:
	# fire_angle is in radiant
	_direction_angle = fire_angle
	self.transform.origin = origin
	self.global_rotation = _direction_angle
	self.set_physics_process(true)
	
func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "MapWalls" or body.name == "Ennemy":
		self.queue_free()
