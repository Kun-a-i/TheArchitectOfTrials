class_name State_idle extends Node

static var player : Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func process(delta: float) -> State:
	player.direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return null 
	
func physics(delta:float) -> State :
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null
