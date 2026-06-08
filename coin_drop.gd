extends Area2D

var gold_value: float = 0.0 
var target_position: Vector2 = Vector2.ZERO
var is_collectible: bool = false

func _ready():
	# === PAKSA FISIK LEWAT KODE ===
	monitoring = true # Paksa mata koin terbuka
	#collision_mask = 1 # Paksa koin hanya memindai Layer 1 (tempat default Player berada)
	# ===============================
	# 1. ANIMASI SEBARAN (0.4 detik)
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_position, 0.4)
	
	modulate.a = 0.4
	
	# 2. JEDA 3 DETIK
	await get_tree().create_timer(3.0).timeout
	
	is_collectible = true
	modulate.a = 1.0 
	print("Koin senilai ", gold_value, " siap diambil!")

# =======================================================
# SISTEM RADAR: Memeriksa tabrakan secara paksa 60x per detik
# =======================================================
func _physics_process(delta):
	if is_collectible:
		var overlapping_bodies = get_overlapping_bodies()
		
		# Jika ada yang menabrak sekecil apa pun, cetak semuanya!
		if overlapping_bodies.size() > 0:
			print("=== RADAR KOIN MENDETEKSI ", overlapping_bodies.size(), " BENDA ===")
			
			for body in overlapping_bodies:
				print("- Nama Benda: ", body.name, " | Tipe Kelas: ", body.get_class())
				
				# Cek alternatif menggunakan nama asli node-nya jika class Player gagal terbaca
				if body is Player or body.name == "Player" or body.name == "CharacterBody2D":
					print("  >> KETEMU PLAYER! MENGAMBIL KOIN!")
					
					body.current_gold += gold_value
					body.current_gold = min(body.current_gold, body.max_quota)
					if body.hud:
						body.hud.update_gold(body.current_gold, body.max_quota)
					
					is_collectible = false 
					queue_free()
					return
