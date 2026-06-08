extends Area2D
class_name CoinToss

@export var speed: float = 500.0
@export var max_range: float = 350.0
@export var noise_duration: float = 2.5

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0
var landed: bool = false

func _physics_process(delta: float) -> void:
	if landed:
		return
	var move = direction * speed * delta
	position += move
	distance_traveled += move.length()
	if distance_traveled >= max_range:
		_land()

func _on_body_entered(_body: Node) -> void:
	if not landed:
		_land()

func _land() -> void:
	if landed:
		return
	landed = true
	add_to_group("noise_source")
	await get_tree().create_timer(noise_duration).timeout
	queue_free()
