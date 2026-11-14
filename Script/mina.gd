extends Area2D

# Cartuchera-mina: cuando el jugador se acerca se enciende la mecha y explota.
@export var radio_deteccion := 130.0
@export var radio_explosion := 110.0
@export var mecha := 0.6   # segundos entre el aviso y la explosion

var armada := false
var explotada := false
var t_vis := 0.0

func _ready():
	collision_layer = 0
	collision_mask = 1
	$Anim.play("idle")
	var forma = CircleShape2D.new()
	forma.radius = radio_deteccion
	$CollisionShape2D.shape = forma
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if armada or explotada:
		return
	if body.is_in_group("jugador"):
		armar()

func armar():
	armada = true
	$Anim.play("alerta")
	# parpadeo rojo/blanco mientras corre la mecha
	var tw = create_tween().set_loops(int(mecha / 0.1))
	tw.tween_property($Anim, "modulate", Color(1, 0.3, 0.3), 0.05)
	tw.tween_property($Anim, "modulate", Color.WHITE, 0.05)
	await get_tree().create_timer(mecha).timeout
	explotar()

func explotar():
	if explotada:
		return
	explotada = true
	$Anim.visible = false
	# solo mata si el jugador sigue dentro del radio de la explosion
	var j = get_tree().get_first_node_in_group("jugador")
	if j and is_instance_valid(j) and j.global_position.distance_to(global_position - Vector2(0, 20)) <= radio_explosion:
		j.morir()
	# efecto visual de la explosion
	t_vis = 0.0
	var tw = create_tween()
	tw.tween_method(_set_vis, 0.0, 1.0, 0.35)
	tw.tween_callback(queue_free)

func _set_vis(v: float):
	t_vis = v
	queue_redraw()

func _draw():
	if not explotada:
		return
	var c = Vector2(0, -20)
	var r = radio_explosion * t_vis
	var a = 1.0 - t_vis
	draw_circle(c, r, Color(1.0, 0.55, 0.1, 0.8 * a))
	draw_circle(c, r * 0.65, Color(1.0, 0.9, 0.3, 0.9 * a))
	draw_circle(c, r * 0.3, Color(1, 1, 1, a))
