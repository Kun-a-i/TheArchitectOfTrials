#extends CharacterBody2D
#
#@export var speed: float = 100.0
#@export var player_path: NodePath  # assign the Player node in the inspector
#
#@onready var player: CharacterBody2D = get_node(player_path)
#@onready var ray: RayCast2D = $RayCast2D
#
#func _physics_process(delta: float) -> void:
	#if not player:
		#return
#
	## Point the ray toward the player
	#var to_player := player.global_position - global_position
	#ray.target_position = to_player
#
	## Update raycast
	#ray.force_raycast_update()
#
	## If ray hits nothing OR directly hits the player, move toward them
	#if not ray.is_colliding() or ray.get_collider() == player:
		#var direction := to_player.normalized()
		#velocity = direction * speed
		#move_and_slide()
	#else:
		#velocity = Vector2.ZERO
		#move_and_slide()
