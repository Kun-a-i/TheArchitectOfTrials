extends State
class_name player_idle

@onready var animation = $"../../PalyerAni"

func Enter():
	print("entering state_idle")
	animation.play("default")
	pass

func Update(_delta:float):
	if Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized():
		state_transition.emit(self, "state_walk")
		
		
	#if Input.is_action_just_pressed("sneak"):
		#state_transition.emit(self, "Sneak")
