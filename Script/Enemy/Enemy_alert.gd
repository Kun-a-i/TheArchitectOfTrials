extends State
class_name Enemy_alert

@onready var ray = $"../../RayCast2D"
@onready var animation = $"../../EnemyAnim"
@export var movespeed := int(180)
var enemy : CharacterBody2D
var player : CharacterBody2D

func Enter():
	print("entering state_alert")
	enemy = $"../.." as CharacterBody2D
	player = get_tree().get_first_node_in_group("Player")

func Update(_delta:float):
	if not Detected():
		state_transition.emit(self, "state_search")
		return
	
	if player:
		# Biar musuh nggak "merasuk" dan nempel mati ke player, kita suruh dia berhenti kalau udah dekat banget
		if enemy.global_position.distance_to(player.global_position) > 40:
			var direction = (player.global_position - enemy.global_position).normalized()
			enemy.velocity = movespeed * direction
		else:
			enemy.velocity = Vector2.ZERO # Berhenti untuk memukul (Attack State nanti di sini)

func UpdatePhysics(delta:float):
	# Sangat bersih! Hanya menghitung arah dan mengatur velocity.
	if player and enemy.global_position.distance_to(player.global_position) > 40:
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity = movespeed * direction
	else:
		enemy.velocity = Vector2.ZERO
	#enemy.move_and_slide()
	
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
	

func Detected():
	if not player:
		return false
	if enemy.global_position.distance_to(player.global_position) > 300: # Jarak pandang saat alert lebih jauh
		return false
		
	# Saat Alert, kita tetap pakai cone vision tapi jauuh lebih lebar (hampir 180 derajat)
	# Agar player tidak terlalu mudah menggocek musuh saat dikejar
	var dir_to_player = (player.global_position - enemy.global_position).normalized()
	if abs(enemy.facing_direction.angle_to(dir_to_player)) > PI/1.5: 
		return false
		
	ray.target_position = ray.to_local(player.global_position)
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.is_in_group("Player"):
			return true
	return false
