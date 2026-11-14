extends Area2D

const VELOCIDAD = 500.0
const DISTANCIA_MAX = 350.0

var direccion = 1
var jugador: Node2D
var origen: Vector2
var regresando = false

func _ready():
	body_entered.connect(_on_body_entered)

func iniciar(pos: Vector2, dir: int, quien: Node2D):
	global_position = pos
	direccion = dir
	jugador = quien
	origen = pos

func _physics_process(delta):
	rotation += 15 * delta

	if not is_instance_valid(jugador):
		queue_free()
		return

	if not regresando:
		global_position.x += direccion * VELOCIDAD * delta
		if abs(global_position.x - origen.x) >= DISTANCIA_MAX:
			regresando = true
	else:
		var objetivo = jugador.global_position
		global_position = global_position.move_toward(objetivo, VELOCIDAD * 1.2 * delta)
		if global_position.distance_to(objetivo) < 20:
			jugador.boomerang_activo = false
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemigo"):
		body.queue_free()
