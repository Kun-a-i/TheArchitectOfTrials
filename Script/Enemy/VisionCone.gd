extends Node2D

var radius: float = 200.0
var fov: float = PI/4
var cone_color: Color = Color(1, 1, 0, 0.2) # Kuning transparan

@onready var enemy = $".."

func _process(_delta):
	if enemy and "facing_direction" in enemy:
		# Putar cone agar sesuai dengan arah hadap musuh
		global_rotation = enemy.facing_direction.angle()
		
		# Sesuaikan warna dan ukuran FOV berdasarkan State saat ini
		var fsm = enemy.get_node_or_null("FSM")
		if fsm and fsm.current_state:
			var state_name = fsm.current_state.name.to_lower()
			if state_name == "state_alert":
				fov = PI/1.5
				radius = 300.0
				cone_color = Color(1, 0, 0, 0.3) # Merah transparan saat Alert
			elif state_name == "state_search":
				fov = PI/3
				radius = 250.0
				cone_color = Color(1, 0.5, 0, 0.3) # Orange transparan saat Search
			else:
				# Patrol / Investigate
				fov = PI/4
				radius = 200.0
				cone_color = Color(1, 1, 0, 0.2) # Kuning transparan saat Patrol
	
	# Minta Godot menggambar ulang (memanggil _draw) setiap frame
	queue_redraw()

func _draw():
	# Menggambar poligon melengkung (seperti potongan pizza)
	var points = PackedVector2Array()
	points.append(Vector2.ZERO)
	
	var num_points = 32
	for i in range(num_points + 1):
		var angle = -fov + i * (fov * 2) / num_points
		# Arah dasar adalah menghadap Kanan (0 derajat)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
		
	var colors = PackedColorArray([cone_color])
	draw_polygon(points, colors)
