extends Node2D

# Ruta de la escena que se carga al llegar a la META
@export_file("*.tscn") var siguiente_nivel := "res://Menu_principal.tscn"
# Si no esta vacio, se muestra este mensaje 3 segundos antes de cambiar de escena
@export var mensaje_al_terminar := ""
# Largo del nivel en pixeles (limite derecho de la camara)
@export var largo_nivel := 4000

var terminado := false

func _ready():
	var cam: Camera2D = $Personaje/Camera2D
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_bottom = 648
	cam.limit_right = largo_nivel
	$Meta.body_entered.connect(_on_meta_body_entered)

func _on_meta_body_entered(body):
	if terminado or not body.is_in_group("jugador"):
		return
	terminado = true
	if mensaje_al_terminar != "":
		$HUD/Mensaje.text = mensaje_al_terminar
		$HUD/Mensaje.visible = true
		await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file.call_deferred(siguiente_nivel)
