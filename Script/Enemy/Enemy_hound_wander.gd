extends State
class_name Enemy_hound_wander

@onready var animation = $"../../EnemyAnim"
@export var movespeed := int(65)
var enemy: CharacterBody2D
var player: Player
var move_direction: Vector2 = Vector2.ZERO
var wander_time: float

func Enter():
	enemy = $"../.." as CharacterBody2D
	player = get_tree().get_first_node_in_group("Player") as Player
	animation.play("default")
	move_direction = Vector2(0, 1).normalized()
	wander_time = 2.0

func Update(_delta: float):
	# Hound buta total — deteksi murni dari suara
	if _can_hear_player():
		state_transition.emit(self, "state_alert")
		return

	if _heard_noise():
		state_transition.emit(self, "state_investigate")
		return

	wander_time -= _delta
	if wander_time <= 0:
		wander_time = 2.0
		move_direction = Vector2(0, -move_direction.y).normalized()
	enemy.velocity = movespeed * move_direction

func UpdatePhysics(_delta: float):
	enemy.move_and_slide()
	if abs(enemy.velocity.x) > abs(enemy.velocity.y):
		if enemy.velocity.normalized().x > 0:
			animation.play("right_anim")
		else:
			animation.play("left_anim")
	else:
		if enemy.velocity.normalized().y > 0:
			animation.play("down_anim")
		else:
			animation.play("up_anim")

func _can_hear_player() -> bool:
	if not is_instance_valid(player):
		return false
	var noise_shape = player.noise_collision.shape
	if not noise_shape is CircleShape2D:
		return false
	var dist = enemy.global_position.distance_to(player.global_position)
	# Minimum 50px agar hound tetap dengar player yang sangat dekat walau agile
	# Minimum hearing range hound — agile tetap terdeteksi dari jarak cukup jauh
	var hearing_range = noise_shape.radius + 80.0
	return dist <= hearing_range

func _heard_noise() -> bool:
	# Hound hyper-sensitive terhadap suara — radius deteksi lebih kecil tapi langsung charge
	var noise_sources = get_tree().get_nodes_in_group("noise_source")
	for source in noise_sources:
		if enemy.global_position.distance_to(source.global_position) <= 200.0:
			enemy.investigate_target = source.global_position
			return true
	return false
