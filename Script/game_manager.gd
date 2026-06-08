extends Node

var is_game_over: bool = false

func game_over():
	# Mencegah fungsi dipanggil berkali-kali jika pemain dipukul saat sedang mati
	if is_game_over: return 
	
	is_game_over = true
	print("=================================")
	print("GAME OVER! Vault Keeper telah gugur.")
	print("Merestart dalam 2 detik...")
	print("=================================")
	
	# Fitur Pause (opsional): Menghentikan sementara pergerakan musuh
	# get_tree().paused = true 
	
	# Menunggu 2 detik secara asinkron
	await get_tree().create_timer(2.0).timeout
	
	# Reset status dan mulai ulang level
	is_game_over = false
	get_tree().reload_current_scene()

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
