extends CharacterBody2D

@export var velocidad := 80.0
@export var rango := 200.0            # cuanto patrulla a cada lado
@export var espera_min := 4.0         # tiempo minimo entre ataques (seg)
@export var espera_max := 7.0         # tiempo maximo entre ataques (seg)
@export var velocidad_ataque := 260.0 # velocidad de la embestida

var direccion := -1
var origen_x := 0.0
var temporizador := 0.0
var atacando := 0.0
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("enemigo")
	origen_x = global_position.x
	temporizador = randf_range(espera_min, espera_max)
	$ZonaDano.body_entered.connect(_on_zona_dano_body_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	if global_position.y > 900:
		queue_free()

	temporizador -= delta
	if atacando > 0:
		# EMBESTIDA: corre hacia donde estaba el jugador (se pone rojo)
		atacando -= delta
		velocity.x = direccion * velocidad_ataque
		$Sprite2D.modulate = Color(1, 0.4, 0.4)
	else:
		$Sprite2D.modulate = Color.WHITE
		var desplazamiento = global_position.x - origen_x
		if desplazamiento >= rango:
			direccion = -1
		elif desplazamiento <= -rango:
			direccion = 1
		if is_on_wall():
			direccion *= -1
		velocity.x = direccion * velocidad
		if temporizador <= 0:
			atacar()

	move_and_slide()
	$Sprite2D.flip_h = direccion > 0

func atacar():
	# Ataque aleatorio: solo si el jugador esta cerca; a veces con salto
	temporizador = randf_range(espera_min, espera_max)
	var j = get_tree().get_first_node_in_group("jugador")
	if j and abs(j.global_position.x - global_position.x) < 500:
		direccion = 1 if j.global_position.x > global_position.x else -1
		atacando = 0.6
		if randf() < 0.5 and is_on_floor():
			velocity.y = -380.0

func _on_zona_dano_body_entered(body):
	if body.is_in_group("jugador"):
		body.morir()
