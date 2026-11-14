extends Area2D

# Fuerza del rebote (pixeles/segundo) y direccion hacia donde lanza.
# Vector2.UP = hacia arriba. Vector2(1, -1.6) = diagonal hacia la derecha.
@export var fuerza := 820.0
@export var direccion := Vector2.UP

var compresion := 0.0   # 0 = suelto, 1 = aplastado (solo visual)

func _ready():
	rotation = direccion.angle() + PI / 2.0
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		body.rebotar(direccion.normalized() * fuerza)
		var t = create_tween()
		t.tween_method(_set_compresion, 1.0, 0.0, 0.35)

func _set_compresion(v: float):
	compresion = v
	queue_redraw()

func _draw():
	# base
	draw_rect(Rect2(-30, -8, 60, 8), Color(0.25, 0.25, 0.3))
	# muelle en zigzag (se encoge al pisarlo)
	var alto = 22.0 * (1.0 - 0.6 * compresion)
	var pts = PackedVector2Array()
	for i in range(7):
		var x = -14.0 if i % 2 == 0 else 14.0
		pts.append(Vector2(x, -8.0 - alto * i / 6.0))
	draw_polyline(pts, Color(0.75, 0.78, 0.85), 4.0)
	# plato superior
	draw_rect(Rect2(-30, -8 - alto - 8, 60, 8), Color(0.9, 0.2, 0.2))
