extends State
class_name Enemy_investigate

@onready var ray = $"../../RayCast2D"
@onready var animation = $"../../EnemyAnim"
@export var movespeed := int(120)
var enemy : CharacterBody2D
var player : CharacterBody2D
var investigate_timer : float = 5.0

func Enter():
	print("entering state_investigate")
	enemy = $"../.." as CharacterBody2D
	player = get_tree().get_first_node_in_group("Player")
	investigate_timer = 5.0
	enemy.velocity = Vector2.ZERO # Untuk sementara diam menginvestigasi

func Update(_delta:float):
	if Detected():
		state_transition.emit(self, "state_alert")
		return
		
	investigate_timer -= _delta
	if investigate_timer <= 0:
		state_transition.emit(self, "state_wander") # Tidak menemukan apa-apa, kembali ke Patrol

func UpdatePhysics(delta:float):
	enemy.move_and_slide()

func Detected():
	if not player:
		return false
	if enemy.global_position.distance_to(player.global_position) > 250:
		return false
		
	# --- CONE OF VISION CHECK ---
	var dir_to_player = (player.global_position - enemy.global_position).normalized()
	if abs(enemy.facing_direction.angle_to(dir_to_player)) > PI/4:
		return false
		
	ray.target_position = ray.to_local(player.global_position)
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.is_in_group("Player"):
			return true
	return false
