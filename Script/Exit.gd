extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	_update_visual()

func _update_visual():
	if not sprite:
		return
	if GameManager.current_stage == 3:
		sprite.modulate = Color(0, 1, 0, 1)    # Hijau = terbuka
	else:
		sprite.modulate = Color(1, 0, 0, 0.6)  # Merah = terkunci

func _process(_delta):
	_update_visual()

func _on_body_entered(body: Node) -> void:
	if not body is Player:
		return
	if GameManager.current_stage == 3:
		print("Berhasil kabur! Mission complete.")
		GameManager.game_win()
	else:
		print("Pintu terkunci. Setor gold ke Altar dulu!")
