extends Area2D

@export var required_quota: float = 50.0

var player_in_area: Player = null

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		deposit_gold()

func deposit_gold():
	if player_in_area.current_gold <= 0.0:
		return
	if player_in_area.current_gold < required_quota:
		return
	player_in_area.current_gold = 0.0
	GameManager.advance_to_escape()

func _on_body_entered(body):
	if body is Player:
		player_in_area = body

func _on_body_exited(body):
	if body is Player:
		player_in_area = null
