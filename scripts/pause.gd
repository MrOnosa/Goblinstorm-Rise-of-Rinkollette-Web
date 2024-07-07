extends Node2D

func _ready() -> void:
	pass

func _process(delta) -> void:
	pass

func _on_menu_button_pressed() -> void:
	get_tree().paused = true
	get_node("CanvasLayer").show()
	get_node("CanvasLayer/Panel/VBoxContainer/ResumeButton").grab_focus()

func _on_resume_button_pressed() -> void:
	get_node("CanvasLayer").hide()
	get_tree().paused = false

func _on_main_menu_button_pressed() -> void:
	get_node("CanvasLayer").hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title.tscn")
