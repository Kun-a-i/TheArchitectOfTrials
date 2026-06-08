extends CharacterBody2D
class_name Player

@onready var fsm = $FSM as FiniteStateMachine
@onready var hud = $HUD

# === KOMPONEN NOISE ===
# Mengambil referensi ke node CollisionShape2D yang baru saja kita buat
@onready var noise_collision = $NoiseArea/CollisionShape2D

# === ENCUMBRANCE & LOOT SYSTEM ===
@export var max_quota: float = 100.0
@export var current_gold: float = 100.0 

# === VARIABEL KNOCKBACK ===
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 500.0  # Seberapa kuat pemain terpental
@export var knockback_friction: float = 2500.0 # Seberapa cepat pemain direm agar tidak meluncur terus

@export var max_health: int = 100
var current_health: int = max_health
var is_dead: bool = false

@export var gold_drain_rate: float = 15.0 # Kehilangan 15 gold per detik jika lari
var is_forcing_agile: bool = false


func get_encumbrance_percentage() -> float:
	return current_gold / max_quota

func get_encumbrance_level() -> String:
	# Jika membuang harta (lari), paksa status jadi Agile (kecepatan max, suara kecil)
	if is_forcing_agile:
		return "agile"
		
	# Logika normalmu di bawah ini
	var percent = get_encumbrance_percentage()
	if percent > 0.7: return "encumbered" 
	elif percent >= 0.3: return "default"    
	else: return "agile"      

func _ready():
	print("=========================================")
	print("WELCOME TO THE ARCHITECT OF TRIALS!")
	print("Sistem Player berhasil dimuat!")
	print("=========================================")

# Ubah _delta menjadi delta
func _physics_process(delta):
	# JIKA MATI, HENTIKAN SEMUA PERGERAKAN DAN INPUT!
	if is_dead:
		# Perlambat sisa knockback lalu diam
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		velocity = knockback_velocity
		move_and_slide()
		queue_redraw()
		return # 'return' ini akan menghentikan eksekusi kode di bawahnya (player tidak bisa jalan/lari lagi)
	# === 1. FITUR DEBUG (Tetap dipertahankan) ===
	if Input.is_physical_key_pressed(KEY_Q):
		current_gold = max(0, current_gold - 1.0)
	elif Input.is_physical_key_pressed(KEY_E):
		current_gold = min(max_quota, current_gold + 1.0)
		
		# === 2. MEKANIK PANIC DROP / FORCED AGILE (Baru) ===
	# Deteksi tombol lari (misal: Shift). Pastikan "ui_sprint" sudah kamu buat di Project Settings -> Input Map.
	# Jika belum buat, kamu bisa pakai "ui_accept" atau tombol fisik untuk tes sementara.
	is_forcing_agile = Input.is_action_pressed("ui_sprint") 
	
	if is_forcing_agile and current_gold > 0.0:
		# Kurangi gold secara perlahan setiap frame
		current_gold -= gold_drain_rate * delta
		current_gold = max(0.0, current_gold) # Pastikan nilainya tidak pernah minus
		
	# === 3. UPDATE SISTEM LAIN (Tetap dipertahankan) ===
	# Memanggil fungsi update radius suara setiap frame agar ukurannya
	# selalu sinkron dengan status beban saat ini (termasuk saat dipaksa Agile).
	_update_noise_radius()
		
	# Update UI Debug di atas kepala
	# Update UI sungguhan
	if hud:
		hud.update_health(current_health, 100) # Ganti 100 dengan variabel max_health jika ada
		hud.update_gold(current_gold, max_quota)
		hud.update_state(get_encumbrance_level())
		
	# queue_redraw() # HAPUS atau comment baris ini
	
	# (Catatan: Jika fungsi move_and_slide() dan pembacaan input arah gerakmu 
	# berada di dalam script FSM, biarkan tetap di sana. Tidak perlu dipanggil di sini.)
	
# === FUNGSI BARU: MENGATUR RADIUS SUARA ===
func _update_noise_radius():
	if noise_collision.shape is CircleShape2D:
		# Hirarki 1: Jika menekan tombol LARI (Panic Drop), suara paling bising!
		if is_forcing_agile:
			noise_collision.shape.radius = 200.0 # Lebih besar dari Encumbered
			
		# Hirarki 2: Jika JALAN BIASA, ukur berdasarkan beban harta
		else:
			var state = get_encumbrance_level()
			if state == "encumbered":
				# Jalan dengan beban penuh (Suara benturan harta berdering)
				noise_collision.shape.radius = 150.0 
			elif state == "default":
				# Jalan dengan beban sedang
				noise_collision.shape.radius = 75.0  
			else:
				# Jalan tanpa beban / Agile (Sangat sunyi, hampir tidak ada area)
				noise_collision.shape.radius = 10.0  

func take_damage(amount: int, attacker_position: Vector2 = Vector2.ZERO):
	# 1. PENGUNCI UTAMA: Jika sudah mati, tolak semua eksekusi kode di bawahnya!
	if is_dead:
		return 
		
	# 2. Kurangi HP
	current_health -= amount
	print("OUCH! Player terkena serangan! Sisa HP: ", current_health)
	
	# 3. Efek Terpental
	if attacker_position != Vector2.ZERO:
		var knockback_direction = attacker_position.direction_to(global_position)
		knockback_velocity = knockback_direction * knockback_strength
	
	# 4. LOGIKA KEMATIAN
	if current_health <= 0:
		is_dead = true # Kunci status mati
		current_health = 0 # Pastikan HP mentok di 0, tidak minus
		
		print("Player telah mati. Melumpuhkan fisik...")
		
		# === SOLUSI BARU: MATIKAN FISIK PEMAIN ===
		# Ini membuat musuh berhenti memukul karena mereka tidak bisa lagi 
		# mendeteksi/menyentuh tubuh pemain.
		$PlayerBound.set_deferred("disabled", true)
		
		# Mematikan area suara agar musuh lain tidak datang
		if has_node("NoiseArea/CollisionShape2D"):
			$NoiseArea/CollisionShape2D.set_deferred("disabled", true)
			
		# Mematikan script FSM agar tidak bisa jalan/lari (jika FSM-mu terpisah)
		if has_node("FSM"):
			$FSM.set_physics_process(false)
			$FSM.set_process(false)
		
		GameManager.game_over()

#func _draw():
	#var font = ThemeDB.fallback_font
	#
	#var text = "HP: " + str(current_health) + " / " + str(max_health) + "\n" # Baris baru untuk HP
	#text += "Gold: " + str(current_gold) + " / " + str(max_quota) + "\n"
	#text += "State: " + get_encumbrance_level().to_upper() + "\n"
	#text += "Speed: " + str(snapped(velocity.length(), 0.1))
	#
	#draw_string(font, Vector2(-50, -70), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.RED)
	#draw_string_outline(font, Vector2(-50, -70), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 2, Color.BLACK)
	#
	## (Kode draw_circle untuk noise tetap biarkan di sini)
	#if noise_collision.shape is CircleShape2D:
		#var current_radius = noise_collision.shape.radius
		#draw_circle(Vector2.ZERO, current_radius, Color(1, 1, 1, 0.2))
