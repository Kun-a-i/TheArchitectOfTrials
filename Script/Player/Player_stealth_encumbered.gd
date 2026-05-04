extends State
class_name Player_stealth_encumbered

@export var movespeed := 50 # Sangat lambat karena tas penuh
var player : CharacterBody2D
@onready var animation = $"../../PalyerAni" # Tetap ikuti typo asli agar tidak error
var input_dir := Vector2.ZERO

func Enter():
	print("Entering State: Stealth (Encumbered) - Beban > 70%")
	player = get_tree().get_first_node_in_group("Player")

func Update(_delta: float):
	# Cek apakah isi tas sudah berkurang
	var encumbrance = player.get_encumbrance_level()
	if encumbrance == "default":
		state_transition.emit(self, "stealth_default")
		return
	elif encumbrance == "agile":
		state_transition.emit(self, "stealth_agile")
		return
		
	# Ambil input gerakan
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_dir = input_dir.normalized()

func UpdatePhysics(_delta: float):
	player.velocity = input_dir * movespeed
	player.move_and_slide()
	
	if input_dir != Vector2.ZERO:
		if abs(player.velocity.x) > abs(player.velocity.y):
			if player.velocity.x > 0:
				animation.play("right_anim")
			else:
				animation.play("left_anim")
		else:
			if player.velocity.y > 0:
				animation.play("down_anim")
			else:
				animation.play("up_anim")
	else:
		animation.play("default") # Animasi diam
