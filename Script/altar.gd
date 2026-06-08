extends Area2D

@export var required_quota: float = 100.0
var current_deposited: float = 0.0
var is_fulfilled: bool = false
var player_in_area: Player = null

# Referensi ke Node UI
@onready var ui_container = $UI
@onready var interaction_label = $UI/InteractionLabel
@onready var progress_label = $UI/ProgressLabel

func _ready():
	# Sembunyikan UI saat awal permainan
	ui_container.hide()
	
	# Pastikan signal terhubung
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	#
	update_altar_ui()

func _process(_delta):
	if player_in_area and not is_fulfilled and Input.is_action_just_pressed("ui_accept"):
		deposit_gold()

func update_altar_ui():
	# Update teks indikator progres (Contoh: 50 / 100)
	progress_label.text = str(current_deposited) + " / " + str(required_quota)
	
	# Jika sudah lunas, ubah teks interaksi
	if is_fulfilled:
		interaction_label.text = "Altar Fulfilled"
		interaction_label.modulate = Color.GOLD
	else:
		interaction_label.text = "[Press Space to fill the altar]"

func deposit_gold():
	if player_in_area.current_gold <= 0.0:
		return

	var amount_needed = required_quota - current_deposited
	var amount_to_deposit = min(player_in_area.current_gold, amount_needed)
	
	current_deposited += amount_to_deposit
	player_in_area.current_gold -= amount_to_deposit
	
	# Update UI setelah deposit
	update_altar_ui()
	
	if player_in_area.hud:
		player_in_area.hud.update_gold(player_in_area.current_gold, player_in_area.max_quota)
		
	if current_deposited >= required_quota:
		is_fulfilled = true
		modulate = Color(1, 0.8, 0) # Altar menyala emas
		GameManager.set_checkpoint(global_position)
		GameManager.altar_completed()

# --- KONEKSI SIGNAL ---

func _on_body_entered(body):
	if body is Player:
		player_in_area = body
		# Munculkan UI saat player mendekat
		ui_container.show()
		update_altar_ui()

func _on_body_exited(body):
	if body is Player:
		player_in_area = null
		# Sembunyikan UI saat player menjauh
		ui_container.hide()
