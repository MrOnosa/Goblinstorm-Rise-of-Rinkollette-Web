extends Node2D

var global : gm
var _backgroundTextureRect : TextureRect
var timeSinceSceneStarted: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	global = get_node("/root/GM") as gm
	_backgroundTextureRect = get_node("CanvasLayer/BackgroundTextureRect")
	
	if global.GameStats != null:
		var statsLabel = get_node("CanvasLayer/StatsLabel")
		statsLabel.text = "Wave %s: You defeated %s Green %s, %s Pink %s, and survived for %s seconds." % [global.GameStats.Wave, global.GameStats.TotalDeadGreenGoblins, "Goblin" if global.GameStats.TotalDeadGreenGoblins == 1 else "Goblins", global.GameStats.TotalDeadPinkGoblins, "Goblin" if global.GameStats.TotalDeadPinkGoblins == 1 else "Goblins", str("%.2f" % global.GameStats.SurvivalTime)]

	var audioPlayer = global.get_node("AudioStreamPlayer")
	audioPlayer.stop()
	audioPlayer.stream = load("res://assets/music/Game_Jam_Rise_of_Rinkollette_Defeat_Music_trimmed_normalized.mp3")
	audioPlayer.play()

	get_node("CanvasLayer/VBoxContainer/RestartButton").grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timeSinceSceneStarted += delta
	var duration: float = 10
	var startValue: float = 0.7
	var endValue: float = 0.3

	var t = max(0, timeSinceSceneStarted - 4) / duration
	t = min(t, 1) 

	var interpolatedValue = startValue + t * (endValue - startValue)
	_backgroundTextureRect.material.set_shader_parameter("difference", interpolatedValue)


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_return_to_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_quit_game_button_pressed():
	get_tree().quit()
