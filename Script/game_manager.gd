extends Node
var is_game_over: bool = false
var last_checkpoint_position: Vector2 = Vector2.ZERO
var player_reference: Node = null # Akan diisi oleh player saat awal mulai

func set_checkpoint(pos: Vector2):
	last_checkpoint_position = pos
	print("Checkpoint disimpan di: ", pos)

# Di dalam game_manager.gd

func game_over():
	if is_game_over: return
	is_game_over = true
	print("Game Over. Mengembalikan ke altar terakhir...")
	
	await get_tree().create_timer(2.0).timeout
	
	if is_instance_valid(player_reference):
		# 1. Pindahkan posisi ke checkpoint
		player_reference.global_position = last_checkpoint_position
		
		# 2. Paksa nyalakan semua variabel internal player
		player_reference.current_health = 100
		player_reference.is_dead = false
		player_reference.velocity = Vector2.ZERO
		
		# 3. Hidupkan kembali fisik tabrakan (PlayerBound)
		player_reference.get_node("PlayerBound").set_deferred("disabled", false)
		
		if player_reference.has_node("NoiseArea/CollisionShape2D"):
			player_reference.get_node("NoiseArea/CollisionShape2D").set_deferred("disabled", false)
			
		# =========================================================
		# KUNCI PENYELAMAT: Bangunkan kembali otak FSM Player!
		# =========================================================
		if player_reference.has_node("FSM"):
			player_reference.get_node("FSM").set_physics_process(true)
			player_reference.get_node("FSM").set_process(true)
			print("Otak FSM dihidupkan kembali!")
			
		# 4. Update HUD
		if player_reference.hud:
			player_reference.hud.update_health(100, 100)
			
	is_game_over = false
	# get_tree().reload_current_scene() # Tetap matikan ini agar koin di lantai tidak hilang

func game_win():
	if is_game_over: return
	
	is_game_over = true
	print("=================================")
	print("MISSION ACCOMPLISHED!")
	print("Harta berhasil diamankan!")
	print("=================================")
	
	await get_tree().create_timer(3.0).timeout
	
	# Untuk MVP, kita restart saja dulu. Nanti bisa diganti ke Main Menu / Level 2
	is_game_over = false
	get_tree().reload_current_scene()
	
func altar_completed():
	print("===========================================")
	print("ALTAR TERSISI! CHECKPOINT BARU DISIMPAN!")
	print("Fase Escape / Alarm Bawah Tanah Dimulai!")
	print("===========================================")
	
	# Nanti di sprint selanjutnya, kita isi fungsi ini dengan:
	# 1. Memutar suara sirine / gempa bumi
	# 2. Membuat kecepatan gerak semua musuh bertambah 20%
	# 3. Membuka pintu rahasia menuju Lantai 2
