class_name State_wandering extends Node

@onready var enemy : CharacterBody2D
@onready var move_speed : float



var wander_time : float
var move_direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func enter() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,3)
	pass
	
func exit() -> void:
	pass
	
func process(delta: float) -> State:
	if wander_time>0:
		wander_time -= delta
	return null 
	
func physics(delta:float) -> State :
	return null
	
func handle_input(_event: InputEvent) -> State:
	return null
