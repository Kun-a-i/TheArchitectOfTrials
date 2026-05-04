extends CharacterBody2D
class_name Player

@onready var fsm = $FSM as FiniteStateMachine

# === ENCUMBRANCE & LOOT SYSTEM ===
@export var max_quota: float = 100.0
@export var current_gold: float = 100.0 

# Dapatkan persentase beban tas saat ini
func get_encumbrance_percentage() -> float:
	return current_gold / max_quota

# Cek status beban saat ini
func get_encumbrance_level() -> String:
	var percent = get_encumbrance_percentage()
	if percent > 0.7:
		return "encumbered" # > 70%
	elif percent >= 0.3:
		return "default"    # 30% - 70%
	else:
		return "agile"      # < 30%

func _ready():
	print("=========================================")
	print("WELCOME TO THE ARCHITECT OF TRIALS!")
	print("Sistem Player berhasil dimuat!")
	print("=========================================")

func _physics_process(_delta):
	# Fitur Debug: Tekan Q untuk mengurangi beban, E untuk menambah beban
	if Input.is_physical_key_pressed(KEY_Q):
		current_gold = max(0, current_gold - 1.0)
	elif Input.is_physical_key_pressed(KEY_E):
		current_gold = min(max_quota, current_gold + 1.0)
		
	queue_redraw() # Panggil _draw() setiap frame untuk update tulisan
	
func _draw():
	var font = ThemeDB.fallback_font
	
	var text = "Gold: " + str(current_gold) + " / " + str(max_quota) + "\n"
	text += " State: " + get_encumbrance_level().to_upper() + "\n"
	text += " Speed: " + str(snapped(velocity.length(), 0.1))
	
	# Gambar teks di atas kepala player (posisi x=-50, y=-50)
	draw_string(font, Vector2(-50, -50), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.RED)
	
	# Gambar outline hitam biar lebih kebaca
	draw_string_outline(font, Vector2(-50, -50), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 2, Color.BLACK)
