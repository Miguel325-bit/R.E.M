extends Area2D

# Tijeras que salen del suelo en los huecos del parkour.
# Solo hacen daño cuando estan abiertas / cerrandose (frames 2 a 4).
@export var retraso := 0.0   # desfase para que no corten todas a la vez

var activa := false

func _ready():
	collision_layer = 0
	collision_mask = 1
	if retraso > 0.0:
		await get_tree().create_timer(retraso).timeout
	$Anim.play("cortar")

func _physics_process(_delta):
	var f: int = $Anim.frame
	activa = f >= 2 and f <= 4
	if not activa:
		return
	for b in get_overlapping_bodies():
		if b.is_in_group("jugador"):
			b.morir()
