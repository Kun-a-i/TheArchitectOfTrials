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

# === SISTEM REGENERASI HP ===
@export var regen_amount: int = 5          # Jumlah HP yang pulih setiap interval
@export var regen_interval: float = 1.5     # Pulih setiap 1.5 detik
@export var safe_time_required: float = 2.0 # Harus aman/tidak dipukul selama 2 detik dulu

var time_since_last_hit: float = 0.0        # Menghitung berapa lama player aman
var regen_timer: float = 0.0                # Menghitung interval 1.5 detik


# === ENCUMBRANCE & LOOT SYSTEM ===
@export var gold_per_sprint_drop: float = 15.0 # Buang 15 gold SEKALIGUS
var sprint_drop_timer: float = 0.0
var sprint_drop_interval: float = 0.4 # Harus terkumpul lari 0.4 detik dulu baru jatuh



# === VARIABEL KNOCKBACK ===
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_strength: float = 500.0
@export var knockback_friction: float = 2500.0

@export var max_health: int = 100
var current_health: int = max_health
var is_dead: bool = false

@export var gold_drain_rate: float = 15.0
var is_forcing_agile: bool = false

var coin_drop: PackedScene = preload("res://coin_drop.tscn") # Nanti di Inspector, masukkan coin_drop.tscn ke sini
@export var gold_lost_on_hit: int = 20

func scatter_coins(amount: int):
	# Cek agar tidak membuang lebih dari yang dimiliki
	var actual_drop = min(amount, current_gold)
	if actual_drop <= 0: return
	
	current_gold -= actual_drop
	hud.update_gold(current_gold, max_quota)
	
	# Spawn beberapa keping koin visual
	var num_coins_to_spawn = min(actual_drop, 10) # Maksimal 10 objek koin agar tidak lag
	var value_per_coin = actual_drop / float(num_coins_to_spawn)
	
	for i in range(num_coins_to_spawn):
		var coin = coin_drop.instantiate()
		
		# Kalkulasi sebaran acak (Radius 40-100 pixel)
		var random_angle = randf_range(0.0, 2.0 * PI)
		var random_distance = randf_range(40.0, 100.0)
		var drop_offset = Vector2.RIGHT.rotated(random_angle) * random_distance
		
		# Atur data koin
		coin.global_position = self.global_position # Mulai dari tubuh player
		coin.target_position = self.global_position + drop_offset
		coin.gold_value = value_per_coin
		
		# Masukkan ke dunia (sebaiknya ke parent root agar tidak ikut player bergerak)
		get_tree().current_scene.add_child(coin)

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
	print("=========================================")
	print("WELCOME TO THE ARCHITECT OF TRIALS!")
	print("Sistem Player berhasil dimuat!")
	print("=========================================")
	# Daftarkan diri ke GameManager
	GameManager.player_reference = self
	
	# Jadikan posisi awal start sebagai checkpoint pertama
	GameManager.set_checkpoint(self.global_position)

func _physics_process(delta):
	if is_dead:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		velocity = knockback_velocity
		move_and_slide()
		return

	# === 2. COIN TOSS ===
	if Input.is_action_just_pressed("coin_toss"):
		_throw_coin()


	# === 4. UPDATE SISTEM LAIN ===
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
	# === 2. MEKANIK PANIC DROP / FORCED AGILE (Chunk Drop & Anti-Exploit) ===
	is_forcing_agile = Input.is_action_pressed("ui_sprint") 
	
	if is_forcing_agile and current_gold > 0.0 and velocity.length() > 0:
		sprint_drop_timer += delta
		
		# Jika total waktu lari sudah menyentuh 0.4 detik
		if sprint_drop_timer >= sprint_drop_interval:
			# Kurangi timer (jangan di set 0 agar sisa milidetiknya tidak hilang/lag)
			sprint_drop_timer -= sprint_drop_interval 
			
			# UI dan fisik dieksekusi bersamaan di dalam fungsi ini!
			drop_sprint_coin(gold_per_sprint_drop)
	else:
		# KUNCI ANTI-EXPLOIT: JANGAN MENG-NOL-KAN TIMER DI SINI!
		# Biarkan timer membeku. Jika player curang menekan shift patah-patah 
		# (0.1s + 0.1s + 0.2s = 0.4s), koin akan TETAP jatuh!
		
		# (Opsional) Timer didinginkan secara perlahan jika player jalan biasa. 
		# Jadi lari sebentar tidak menghukum, tapi spam-klik akan tetap dihukum.
		sprint_drop_timer = max(0.0, sprint_drop_timer - (delta * 0.5))
	if current_health < max_health:
		time_since_last_hit += delta # Hitung seberapa lama player berhasil kabur
		
		# KONDISI 1: Apakah sudah berhasil kabur selama 2 detik?
		if time_since_last_hit >= safe_time_required:
			regen_timer += delta # Mulai hitung interval penyembuhan
			
			# KONDISI 2: Apakah interval 1.5 detik sudah tercapai?
			if regen_timer >= regen_interval:
				regen_timer = 0.0 # Reset timer interval untuk cicilan berikutnya
				
				# Tambah HP dan pastikan tidak melebihi batas max_health
				current_health = min(max_health, current_health + regen_amount)
				print("HP Beregenerasi! +5 HP. HP saat ini: ", current_health)
				
	else:
		# Jika HP sudah penuh, bersihkan timer agar tidak membebani memori
		time_since_last_hit = 0.0
		regen_timer = 0.0

	# === 4. UPDATE SISTEM LAIN (Update HUD dll) ===
	#_update_noise_radius()
	_update_noise_radius()

	if hud:
		hud.update_health(current_health, max_health)
		hud.update_gold(current_gold, max_quota)
		hud.update_state(get_encumbrance_level())

	
	
# === FUNGSI BARU: MENGATUR RADIUS SUARA ===
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
	print("OUCH! Player terkena serangan! Sisa HP: ", current_health)
	# =========================================================
	# RESET TIMER REGEN (BARU)
	# =========================================================
	time_since_last_hit = 0.0 # Baru dipukul, waktu aman kembali ke nol!
	regen_timer = 0.0         # Reset juga timer cicilan HP-nya
	# =========================================================
	
	scatter_coins(gold_lost_on_hit)
	# 3. Efek Terpental
	if attacker_position != Vector2.ZERO:
		var knockback_direction = attacker_position.direction_to(global_position)
		knockback_velocity = knockback_direction * knockback_strength
	
	
	# 4. LOGIKA KEMATIAN
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
		
func drop_sprint_coin(amount: float):
	var actual_drop = min(amount, current_gold)
	if actual_drop <= 0: return
	
	current_gold -= actual_drop
	if hud:
		hud.update_gold(current_gold, max_quota)
		
	# Instansiasi koin tunggal
	var coin = coin_drop.instantiate()
	
	# Cari arah kebalikan dari lari untuk menjatuhkan koin di BELAKANG player
	var drop_direction = -velocity.normalized()
	if drop_direction == Vector2.ZERO:
		drop_direction = Vector2.DOWN # Cadangan jika posisi diam
		
	# Beri sedikit variasi acak agar tidak terlalu lurus kaku
	var random_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	var target_pos = global_position + (drop_direction * randf_range(15, 30)) + random_offset
	
	coin.global_position = global_position
	coin.target_position = target_pos
	coin.gold_value = actual_drop
	
	get_tree().current_scene.add_child(coin)
