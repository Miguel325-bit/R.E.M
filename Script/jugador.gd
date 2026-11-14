extends CharacterBody2D

const VELOCIDAD = 300.0
const SALTO = -450.0
var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")

var mirando = 1
var boomerang_activo = false
var muerto = false
var empuje_x = 0.0   # impulso horizontal que dejan los resortes
var escena_boomerang = preload("res://Personajes/boomerang.tscn")

func _ready():
	add_to_group("jugador")

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_0 or event.keycode == KEY_KP_0:
			if not boomerang_activo and not muerto:
				lanzar()

func _physics_process(delta):
	if muerto:
		return

	if not is_on_floor():
		velocity.y += gravedad * delta

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = SALTO

	var dir = Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		mirando = int(sign(dir))
	velocity.x = dir * VELOCIDAD + empuje_x
	empuje_x = move_toward(empuje_x, 0.0, 1500.0 * delta)
	move_and_slide()

	animar(dir)

	# Si se cae del mapa, reinicia el nivel
	if global_position.y > 760:
		morir()

func animar(dir):
	var anim = "quieto"
	if not is_on_floor():
		anim = "salto" if velocity.y < 0 else "caer"
	elif dir != 0:
		anim = "avanzar"
	elif Input.is_action_pressed("ui_down"):
		anim = "agachado"
	if dir != 0:
		$AnimatedSprite2D.flip_h = dir < 0
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)

func lanzar():
	boomerang_activo = true
	var b = escena_boomerang.instantiate()
	get_parent().add_child(b)
	b.iniciar(global_position, mirando, self)

func rebotar(v: Vector2):
	velocity.y = v.y
	empuje_x = v.x

func morir():
	if muerto:
		return
	muerto = true
	get_tree().reload_current_scene.call_deferred()
