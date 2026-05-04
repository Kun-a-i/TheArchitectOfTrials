extends State
class_name Player_walk


@export var movespeed := int(100)

var player : CharacterBody2D
@onready var animation = $"../../PalyerAni"
var input_dir := Vector2.ZERO
func Enter():
	print("entering state_walk")
	player = get_tree().get_first_node_in_group("Player")
	pass

func Update(_delta:float):
	if Input.is_action_just_pressed("move_down"):
		print("Debug: Tombol DOWN ditekan!")
	if Input.is_action_just_pressed("move_up"):
		print("Debug: Tombol UP ditekan!")
	if Input.is_action_just_pressed("move_left"):
		print("Debug: Tombol LEFT ditekan!")
	if Input.is_action_just_pressed("move_right"):
		print("Debug: Tombol RIGHT ditekan!")

	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if input_dir == Vector2.ZERO:
		state_transition.emit(self, "state_idle")

func UpdatePhysics(delta:float):
	if input_dir != Vector2.ZERO:
		Move(input_dir)
		
	if abs(player.velocity.x) > abs(player.velocity.y):
		if player.velocity.normalized().x>0:
			animation.play("right_anim")
		else :
			animation.play("left_anim")
	else :
		if player.velocity.normalized().y>0:
			animation.play("down_anim")
		else :
			animation.play("up_anim")

func Exit():
	animation.stop()
	
func Move(input_dir : Vector2):
	player.velocity = input_dir*movespeed
	player.move_and_slide()
