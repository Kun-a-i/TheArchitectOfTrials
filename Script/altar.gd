extends Area2D

# Variabel untuk menyimpan referensi player jika dia masuk ke area
var player_in_area: Player = null

func _process(_delta):
	# Mengecek jika player ada di area dan menekan tombol interaksi (Spasi/Enter)
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		deposit_gold()

func deposit_gold():
	if player_in_area.current_gold > 0.0:
		print("Berhasil menyetor ", player_in_area.current_gold, " gold ke Altar!")
		# Mereset gold pemain menjadi 0
		player_in_area.current_gold = 0.0
		
		# Nanti di sini kita bisa panggil sinyal ke Game Manager 
		# untuk memicu status "Awakened" pada Dungeon
	else:
		print("Bebanmu sudah kosong, tidak ada yang disetor.")

# --- KONEKSI SIGNAL AREA2D ---
# Jangan lupa hubungkan signal body_entered dan body_exited dari node Area2D ke script ini!

func _on_body_entered(body):
	print("DEBUG: Ada sesuatu yang masuk ke area bernama: ", body.name) # Tambahkan baris ini
	
	if body is Player:
		player_in_area = body
		print("Pemain di dekat Altar. Tekan SPASI/ENTER untuk deposit.")
func _on_body_exited(body):
	if body is Player:
		player_in_area = null
		print("Pemain menjauhi Altar.")
