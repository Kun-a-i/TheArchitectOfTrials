extends CharacterBody2D
class_name Enemy

@onready var fsm = $FSM as FiniteStateMachine
var facing_direction: Vector2 = Vector2(0, 1)

func _physics_process(_delta):
	if velocity != Vector2.ZERO:
		facing_direction = velocity.normalized()
