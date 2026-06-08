extends State
class_name Enemy_phantom_wander

@onready var ray = $"../../RayCast2D"
@onready var animation = $"../../EnemyAnim"
@export var movespeed := int(60)
var enemy: CharacterBody2D
var player: CharacterBody2D
var move_direction: Vector2 = Vector2.ZERO
var wander_time: float

func Enter():
	print("entering state_wander (phantom)")
	enemy = $"../.." as CharacterBody2D
	player = get_tree().get_first_node_in_group("Player")
	animation.play("default")
	move_direction = Vector2(0, 1).normalized()
	wander_time = 2.0

func Update(_delta: float):
	# Phantom punya vision hampir 360 derajat — tidak bisa disembunyi dari pandangannya
	if Detected():
		state_transition.emit(self, "state_alert")
		return
	# Phantom sepenuhnya ignore suara/koin — tidak ada _heard_noise()

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

func Detected() -> bool:
	if not player:
		return false
	# Phantom punya jarak deteksi sedikit lebih pendek tapi FOV hampir penuh (330 derajat)
	if enemy.global_position.distance_to(player.global_position) > 180:
		return false
	var dir_to_player = (player.global_position - enemy.global_position).normalized()
	if abs(enemy.facing_direction.angle_to(dir_to_player)) > PI / 1.09:
		return false
	ray.target_position = ray.to_local(player.global_position)
	ray.force_raycast_update()
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.is_in_group("Player"):
			return true
	return false
