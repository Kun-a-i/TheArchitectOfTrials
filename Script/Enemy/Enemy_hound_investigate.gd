extends State
class_name Enemy_hound_investigate

@onready var animation = $"../../EnemyAnim"
@export var movespeed := int(100)
var enemy: CharacterBody2D
var player: Player
var investigate_timer: float = 5.0

func Enter():
	enemy = $"../.." as CharacterBody2D
	player = get_tree().get_first_node_in_group("Player") as Player
	investigate_timer = 5.0

func Update(_delta: float):
	# Hound tidak punya vision — deteksi player murni dari suara langkah
	if _can_hear_player():
		enemy.investigate_target = player.global_position
		state_transition.emit(self, "state_alert")
		return

	var dist = enemy.global_position.distance_to(enemy.investigate_target)
	if dist > 15.0:
		var dir = (enemy.investigate_target - enemy.global_position).normalized()
		enemy.velocity = dir * movespeed
	else:
		enemy.velocity = Vector2.ZERO
		investigate_timer -= _delta
		if investigate_timer <= 0:
			state_transition.emit(self, "state_wander")

func UpdatePhysics(_delta: float):
	enemy.move_and_slide()
	if enemy.velocity != Vector2.ZERO:
		if abs(enemy.velocity.x) > abs(enemy.velocity.y):
			if enemy.velocity.x > 0:
				animation.play("right_anim")
			else:
				animation.play("left_anim")
		else:
			if enemy.velocity.y > 0:
				animation.play("down_anim")
			else:
				animation.play("up_anim")
	else:
		animation.play("default")

func _can_hear_player() -> bool:
	if not is_instance_valid(player):
		return false
	# Pakai noise radius player yang sudah ada — semakin berat beban, semakin jauh kedengeran
	var noise_shape = player.noise_collision.shape
	if not noise_shape is CircleShape2D:
		return false
	var noise_radius = noise_shape.radius
	var dist = enemy.global_position.distance_to(player.global_position)
	return dist <= noise_radius
