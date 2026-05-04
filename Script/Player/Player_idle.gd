extends State
class_name player_idle

@onready var animation = $"../../PalyerAni"

func Enter():
	print("entering state_idle")
	animation.play("default")
	pass

func Update(_delta:float):
	if Input.is_action_just_pressed("move_down"):
		print("Debug: Tombol DOWN ditekan (di Idle)!")
	if Input.is_action_just_pressed("move_up"):
		print("Debug: Tombol UP ditekan (di Idle)!")
	if Input.is_action_just_pressed("move_left"):
		print("Debug: Tombol LEFT ditekan (di Idle)!")
	if Input.is_action_just_pressed("move_right"):
		print("Debug: Tombol RIGHT ditekan (di Idle)!")

	if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
		state_transition.emit(self, "state_walk")
		
	#if Input.is_action_just_pressed("sneak"):ad
		#state_transition.emit(self, "Sneak")
