extends State
class_name Enemy_search

@onready var ray = $"../../RayCast2D"
@onready var animation = $"../../EnemyAnim"
var enemy : CharacterBody2D
var player : CharacterBody2D
var search_timer : float = 15.0

var change_dir_timer : float = 0.0

func Enter():
	print("entering state_search")
	enemy = $"../.." as CharacterBody2D
	player = get_tree().get_first_node_in_group("Player")
	search_timer = 15.0
	change_dir_timer = 0.0

func Update(_delta:float):
	if Detected():
		state_transition.emit(self, "state_alert")
		return
		
	search_timer -= _delta
	if search_timer <= 0:
		state_transition.emit(self, "state_wander") # Kembali ke Patrol

	change_dir_timer -= _delta
	if change_dir_timer <= 0:
		change_dir_timer = 1.5 # Ganti arah tiap 1.5 detik
		# Pilih arah acak secara memutar (melihat sekeliling)
		var random_angle = randf() * PI * 2
		enemy.velocity = Vector2(cos(random_angle), sin(random_angle)) * 70 # Jalan pelan sambil waspada

func UpdatePhysics(delta:float):
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

func Detected():
	if not player:
		return false
	if enemy.global_position.distance_to(player.global_position) > 250:
		return false
		
	# --- CONE OF VISION CHECK ---
	var dir_to_player = (player.global_position - enemy.global_position).normalized()
	# Di Search state, mungkin penglihatannya lebih awas / lebar
	if abs(enemy.facing_direction.angle_to(dir_to_player)) > PI/3: # 120 derajat FOV
		return false
		
	ray.target_position = ray.to_local(player.global_position)
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.is_in_group("Player"):
			return true
	return false
