extends State
class_name Player_stealth_agile

@export var movespeed := 250.0 
var player : CharacterBody2D
@onready var animation = $"../../PalyerAni"
var input_dir := Vector2.ZERO

func Enter():
	print("Entering State: Stealth (Agile) - Beban < 30%")
	player = get_tree().get_first_node_in_group("Player")

func Update(_delta: float):
	var encumbrance = player.get_encumbrance_level()
	if encumbrance == "encumbered":
		state_transition.emit(self, "stealth_encumbered")
		return
	elif encumbrance == "default":
		state_transition.emit(self, "stealth_default")
		return
		
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
		animation.play("default")
