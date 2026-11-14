extends StaticBody2D

# Plataforma que se puede atravesar desde abajo (salta y aterriza encima)
@export var ancho := 200.0

func _ready():
	var forma = RectangleShape2D.new()
	forma.size = Vector2(ancho, 20)
	$CollisionShape2D.shape = forma
	queue_redraw()

func _draw():
	draw_rect(Rect2(-ancho / 2.0, -10, ancho, 20), Color(0.45, 0.3, 0.18))
	draw_rect(Rect2(-ancho / 2.0, -10, ancho, 6), Color(0.35, 0.75, 0.3))
