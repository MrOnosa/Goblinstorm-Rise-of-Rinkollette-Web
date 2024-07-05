extends Node2D

var global = null

# Called when the node enters the scene tree for the first time.
func _ready():
	global = get_node("/root/GM")
	
	var audioPlayer = global.get_node("AudioStreamPlayer")
	audioPlayer.stop()
	audioPlayer.stream = load("res://assets/music/RoR_Credits_Song_trimmed_normalized.mp3")
	audioPlayer.play()
	
	get_node("CanvasLayer/Button").grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title.tscn")
