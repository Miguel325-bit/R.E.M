extends CharacterBody2D

# Borrador con lapiz: patrulla, y si ve al jugador se prepara y le EMBISTE.
enum Estado { PATRULLA, PREPARAR, EMBESTIDA, ATURDIDO }

@export var velocidad := 70.0
@export var rango := 180.0                 # cuanto patrulla a cada lado
@export var distancia_deteccion := 450.0   # a que distancia ve al jugador
@export var altura_deteccion := 130.0      # diferencia de altura maxima para verlo
@export var tiempo_preparar := 0.55        # aviso antes de embestir
@export var velocidad_embestida := 560.0
@export var duracion_embestida := 0.8
@export var tiempo_aturdido := 1.1         # descanso tras embestir
@export var enfriamiento := 1.5            # espera minima entre embestidas

var estado := Estado.PATRULLA
var direccion := -1
var origen_x := 0.0
var reloj := 0.0
var frio := 0.0
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("enemigo")
	origen_x = global_position.x
	$ZonaDano.body_entered.connect(_on_zona_dano_body_entered)
	$Anim.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	if global_position.y > 900:
		queue_free()
		return

	frio = max(0.0, frio - delta)
	reloj -= delta

	match estado:
		Estado.PATRULLA:
			_patrullar()
		Estado.PREPARAR:
			velocity.x = 0.0
			# tiembla antes de salir disparado
			$Anim.position.x = randf_range(-2.0, 2.0)
			if reloj <= 0.0:
				$Anim.position.x = 0.0
				_iniciar_embestida()
		Estado.EMBESTIDA:
			velocity.x = direccion * velocidad_embestida
			if reloj <= 0.0 or is_on_wall():
				_aturdir()
		Estado.ATURDIDO:
			velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
			if reloj <= 0.0:
				estado = Estado.PATRULLA
				$Anim.play("idle")

	move_and_slide()
	$Anim.flip_h = direccion > 0

func _patrullar():
	var d = global_position.x - origen_x
	if d >= rango:
		direccion = -1
	elif d <= -rango:
		direccion = 1
	if is_on_wall():
		direccion *= -1
	velocity.x = direccion * velocidad

	var j = get_tree().get_first_node_in_group("jugador")
	if frio <= 0.0 and j and not j.muerto:
		var dx = j.global_position.x - global_position.x
		var dy = abs(j.global_position.y - global_position.y)
		if abs(dx) < distancia_deteccion and dy < altura_deteccion:
			direccion = 1 if dx > 0 else -1
			estado = Estado.PREPARAR
			reloj = tiempo_preparar
			$Anim.play("preparar")

func _iniciar_embestida():
	# se lanza hacia donde esta el jugador en este momento
	var j = get_tree().get_first_node_in_group("jugador")
	if j:
		direccion = 1 if j.global_position.x > global_position.x else -1
	estado = Estado.EMBESTIDA
	reloj = duracion_embestida
	$Anim.play("embestida")

func _aturdir():
	estado = Estado.ATURDIDO
	reloj = tiempo_aturdido
	frio = enfriamiento + tiempo_aturdido
	$Anim.play("aturdido")

func _on_zona_dano_body_entered(body):
	if body.is_in_group("jugador"):
		body.morir()
