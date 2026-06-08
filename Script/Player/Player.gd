extends CharacterBody2D
class_name Player

const CoinTossPrefab = preload("res://coin_toss.tscn")

@onready var fsm = $FSM as FiniteStateMachine
@onready var hud = $HUD

# === KOMPONEN NOISE ===
@onready var noise_collision = $NoiseArea/CollisionShape2D

# === ENCUMBRANCE & LOOT SYSTEM ===
@export var max_quota: float = 100.0
@export var current_gold: float = 100.0

# === VARIABEL KNOCKBACK ===
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 500.0
@export var knockback_friction: float = 2500.0

@export var max_health: int = 100
var current_health: int = max_health
var is_dead: bool = false

@export var gold_drain_rate: float = 15.0
var is_forcing_agile: bool = false


func get_encumbrance_percentage() -> float:
	return current_gold / max_quota

func get_encumbrance_level() -> String:
	if is_forcing_agile:
		return "agile"
	var percent = get_encumbrance_percentage()
	if percent > 0.7: return "encumbered"
	elif percent >= 0.3: return "default"
	else: return "agile"

func _ready():
	var spawn = get_tree().get_first_node_in_group("SpawnPoint")
	if spawn:
		global_position = spawn.global_position

func _physics_process(delta):
	if is_dead:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		velocity = knockback_velocity
		move_and_slide()
		return

	# === 2. COIN TOSS ===
	if Input.is_action_just_pressed("coin_toss"):
		_throw_coin()

	# === 3. MEKANIK PANIC DROP / FORCED AGILE ===
	is_forcing_agile = Input.is_action_pressed("ui_sprint")

	if is_forcing_agile and current_gold > 0.0:
		current_gold -= gold_drain_rate * delta
		current_gold = max(0.0, current_gold)

	# === 4. UPDATE SISTEM LAIN ===
	_update_noise_radius()

	if hud:
		hud.update_health(current_health, max_health)
		hud.update_gold(current_gold, max_quota)
		hud.update_state(get_encumbrance_level())

func _update_noise_radius():
	if noise_collision.shape is CircleShape2D:
		if is_forcing_agile:
			noise_collision.shape.radius = 200.0
		else:
			var state = get_encumbrance_level()
			if state == "encumbered":
				noise_collision.shape.radius = 150.0
			elif state == "default":
				noise_collision.shape.radius = 75.0
			else:
				noise_collision.shape.radius = 10.0

func _throw_coin() -> void:
	const COIN_COST = 10.0
	if get_encumbrance_level() == "agile" or current_gold < COIN_COST:
		return
	var coin = CoinTossPrefab.instantiate()
	coin.global_position = global_position
	coin.direction = (get_global_mouse_position() - global_position).normalized()
	get_parent().add_child(coin)
	current_gold -= COIN_COST

func take_damage(amount: int, attacker_position: Vector2 = Vector2.ZERO):
	if is_dead:
		return
	current_health -= amount

	if attacker_position != Vector2.ZERO:
		var knockback_direction = attacker_position.direction_to(global_position)
		knockback_velocity = knockback_direction * knockback_strength

	if current_health <= 0:
		is_dead = true
		current_health = 0
		$PlayerBound.set_deferred("disabled", true)
		if has_node("NoiseArea/CollisionShape2D"):
			$NoiseArea/CollisionShape2D.set_deferred("disabled", true)
		if has_node("FSM"):
			$FSM.set_physics_process(false)
			$FSM.set_process(false)
		GameManager.game_over()
