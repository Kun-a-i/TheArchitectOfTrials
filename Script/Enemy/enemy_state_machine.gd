class_name Enemy_state_machine extends Node

var states : Array[State] = []
var current_state : State = null
var prev_state : State = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	pass # Replace with function body.

func Initialize(_enemy : Enemy) ->void:
	states =[]
	for state in get_children():
		states.append(state)
	
	if states.size() > 0 :
		states[0].enemy = _enemy
		ChangeState(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ChangeState(current_state.process(delta))
	pass

func _physics(delta:float) -> void :
	ChangeState(current_state.process(delta))
	pass
	
func _unhandeled_input(event) -> void:
	ChangeState(current_state.handle_input(event))
	pass



func ChangeState(next_state : State) -> void:
	if next_state == null || next_state == current_state:
		return
	if current_state :
		current_state.exit()
	
	prev_state = current_state
	current_state = next_state
	current_state.enter()
	pass
