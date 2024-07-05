extends Control

var global = null
var _soundTest: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Setting up title...")
	global = get_node("/root/GM")
	var audioPlayer = global.get_node("AudioStreamPlayer")
	
	if audioPlayer.stream == null or audioPlayer.stream.resource_path != "res://assets/music/Game_Jam_Rise_of_Rinkollette_Title_Song_trimmed_normalized.mp3":
		audioPlayer.stream = load("res://assets/music/Game_Jam_Rise_of_Rinkollette_Title_Song_trimmed_normalized.mp3")
		audioPlayer.play()
		
	get_node("StartButton").grab_focus()

	var slider = get_node("VolumeSlider")
	slider.value = global.Volume * 100
	
	var sfxSlider = get_node("SfxVolumeSlider")
	sfxSlider.value = global.SfxVolume * 100
	_soundTest = true

	var fullScreenCheckButton : CheckButton = get_node("FullScreenCheckButton")
	fullScreenCheckButton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_start_button_pressed():
	global.GoblinMode = false
	get_tree().change_scene("res://scenes/level.tscn")

func _on_start_goblin_mode_button_pressed():
	global.GoblinMode = true
	get_tree().change_scene("res://scenes/level.tscn")

func _on_credits_button_pressed():
	get_tree().change_scene("res://scenes/credits.tscn")

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_volume_slider_value_changed(value):
	global.set_volume(value / 100.0)

func _on_sfx_volume_slider_value_changed(value):
	global.set_sfx_volume(value / 100.0, _soundTest)

func _on_full_screen_check_button_toggled(value):
	# Fullscreen broke. It doesn't seem to want to 
	# go back to windowed mode. I'm not sure why
	if value:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var root = get_node("/root")
		root.borderless = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
	
