extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var gold_label = $GoldLabel
@onready var state_label = $StateLabel

# Fungsi untuk dipanggil oleh Player
func update_health(current: int, maximum: int):
	health_bar.max_value = maximum
	health_bar.value = current

func update_gold(current: float, quota: float):
	# %d akan mengubah angka desimal (float) menjadi bilangan bulat (integer) di layar
	gold_label.text = "Gold: %d / %d" % [current, quota]

func update_state(state: String):
	state_label.text = "Status: " + state.to_upper()
