extends Control

@onready var button_sound: AudioStreamPlayer = $ButtonSound


func _on_8way_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://scenes/movements/8way_movement.tscn")


func _on_mouse_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://scenes/movements/mouse_movement.tscn")


func _on_car_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://scenes/movements/car_movement.tscn")


func _on_quit_pressed() -> void:
	button_sound.play()
	get_tree().quit()
