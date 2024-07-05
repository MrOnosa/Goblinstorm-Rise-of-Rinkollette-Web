extends Node2D

var global

# Called when the node enters the scene tree for the first time.
func _ready():
	global = get_node("/root/GM") as gm

	if global.GameStats != null:
		var statsLabel = get_node("CanvasLayer/StatsLabel")
		statsLabel.text = "You completed the game in %s seconds." % str("%.2f" % global.GameStats.SurvivalTime)

	var audioPlayer = global.get_node("AudioStreamPlayer")
	audioPlayer.stop()
	audioPlayer.stream = load("res://assets/music/Game_Jam_Rise_of_Rinkollette_Victory_Song_trimmed_normalized.mp3")
	audioPlayer.play()

	get_node("CanvasLayer/VBoxContainer/RestartButton").grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")

func _on_return_to_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_quit_game_button_pressed():
	get_tree().quit()
