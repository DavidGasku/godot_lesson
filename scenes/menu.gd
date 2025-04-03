extends Control

@onready var button_sound: AudioStreamPlayer = $ButtonSound


func _on_play_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://scenes/ball1.tscn")


func _on_settings_pressed() -> void:
	button_sound.play()
	get_tree().change_scene_to_file("res://scenes/ball2.tscn")



func _on_quit_pressed() -> void:
	button_sound.play()
	get_tree().quit()
