extends CharacterBody2D
class_name Enemy

@onready var fsm = $FSM as FiniteStateMachine
var facing_direction: Vector2 = Vector2(0, 1)


var player_in_attack_range: Player = null
var attack_cooldown: float = 0.0
var attack_rate: float = 1.5 # Musuh akan menyerang setiap 1.5 detik

var recoil_velocity: Vector2 = Vector2.ZERO
@export var recoil_strength: float = 800.0  # Kekuatan lompat mundur (sesuaikan agar pas keluar attack range)
@export var recoil_friction: float = 3000.0 # Gesekan agar musuh berhenti dengan halus

func _physics_process(delta):
	# --- Logika Menghadap ---
	if velocity != Vector2.ZERO:
		facing_direction = velocity.normalized()
		
	# --- Logika Recoil ---
	# Jika musuh sedang terpental, kurangi kecepatannya secara perlahan (friction)
	if recoil_velocity != Vector2.ZERO:
		recoil_velocity = recoil_velocity.move_toward(Vector2.ZERO, recoil_friction * delta)
		
		# Ambil alih pergerakan (timpa velocity dari FSM) selama recoil masih kencang
		if recoil_velocity.length() > 50.0:
			velocity = recoil_velocity
			
	# Pastikan ada pemanggilan move_and_slide() agar musuh benar-benar bergerak
	# (Jika di dalam script FSM-mu sudah ada move_and_slide(), kamu mungkin tidak perlu baris ini di sini)
	move_and_slide()


func _process(delta):
	# Jika pemain berada di dalam jangkauan serangan
	if player_in_attack_range != null:
		attack_cooldown -= delta 
		
		if attack_cooldown <= 0.0:
			# 1. Berikan damage ke pemain (Bisa memicu reload scene jika HP habis)
			player_in_attack_range.take_damage(20) 
			attack_cooldown = attack_rate         
			
			# 2. CEK VALIDITAS: Pastikan pemain belum hancur (game over) sebelum mengambil posisinya
			if is_instance_valid(player_in_attack_range):
				# Hitung arah dari posisi PEMAINKU menuju posisi MUSUH INI
				var recoil_dir = player_in_attack_range.global_position.direction_to(global_position)
				
				# Berikan dorongan mundur seketika
				recoil_velocity = recoil_dir * recoil_strength
				print("BAM! Musuh memukul dan melompat mundur!")
			else:
				# Jika pemain sudah tidak valid (mati), kosongkan referensinya
				player_in_attack_range = null

func _on_attack_area_body_entered(body):
	print("DEBUG MUSUH: Ada yang masuk ke area serang! Namanya: ", body.name)
	
	if body is Player:
		print("DEBUG MUSUH: Target dikunci! Memulai cooldown serangan.")
		player_in_attack_range = body
		attack_cooldown = 0.0

func _on_attack_area_body_exited(body):
	if body is Player:
		player_in_attack_range = null # Kosongkan referensi agar musuh berhenti menyerang
		print("Pemain berhasil kabur dari jangkauan serangan musuh!")
