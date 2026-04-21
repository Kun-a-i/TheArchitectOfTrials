class_name Player extends CharacterBody2D

@export var speed: float = 100.0

# Reference to the AnimatedSprite2D node
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

#Reference the states
@onready var state_machine : Player_state_machine = $state


var direction := Vector2.ZERO

func _ready() -> void:
	state_machine.Initialize(self)
	pass


func _physics_process(delta: float) -> void:
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up") 
	
	if direction != Vector2.ZERO && (Input.is_action_pressed("move_down") || Input.is_action_pressed("move_up") || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right")):
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide()

		# Play walk animation depending on direction
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				anim.play("Right_ani")
			else:
				anim.play("Left_ani")
		else:
			if direction.y > 0:
				anim.play("Down_ani")
			else:
				anim.play("Up_ani")
	else:
		velocity = Vector2.ZERO
		move_and_slide() # fallback idle animation#
		anim.play("Down_default")
