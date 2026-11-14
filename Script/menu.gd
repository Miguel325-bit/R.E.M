extends Node2D

func _ready():
	$CanvasLayer/CanvasModulate/Button.pressed.connect(_on_button_pressed)
	$CanvasLayer/CanvasModulate/Button2.pressed.connect(_on_button_2_pressed)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Niveles/Nivel1.tscn")

func _on_button_2_pressed():
	get_tree().quit()
