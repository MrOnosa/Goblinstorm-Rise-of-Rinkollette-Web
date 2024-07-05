extends Node
class_name gm

@export var UsingController: bool
@export var Volume: float
@export var SfxVolume: float

var audio_stream_player : AudioStreamPlayer

var GameStats : Stats;
var GoblinMode: bool = false

# Tutorial Flags
var EverHeldItem: bool = false
var EverHeldCorrectItem: bool = false
var EverKilledGoblin: bool = false
var EverGotPastWaveOne: bool = false
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Setting up global...")
	audio_stream_player = $AudioStreamPlayer
	UsingController = false
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		# Try creating one instead
		config = ConfigFile.new()
		config.set_value("Options", "volume", Volume)
		config.set_value("Options", "sfx_volume", SfxVolume)
		config.save("user://settings.cfg")
	else:
		Volume = config.get_value("Options", "volume")
		SfxVolume = config.get_value("Options", "sfx_volume")

	set_volume(Volume)
	set_sfx_volume(SfxVolume)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !UsingController and any_controller_input():
		# Player swapped from Keyboard & Mouse to controller
		UsingController = true
		toggle_mouse(!UsingController)
	elif UsingController and any_keyboard_and_mouse_input():
		# Player swapped from controller to Keyboard & Mouse
		UsingController = false
		toggle_mouse(!UsingController)

func convert_volume_to_db_volume(volume):
	var dbVolume = linear_to_db(volume)
	if dbVolume > 3.0:
		dbVolume = 3.0
	return dbVolume

func set_volume(volume):
	Volume = volume
	var dbVolume = convert_volume_to_db_volume(Volume)
	audio_stream_player.volume_db = dbVolume
	print("dbVolume " + str(dbVolume))

	# Save setting to config after a moment
	var timer = get_node("SettingsDebouncingTimer")
	if timer:
		timer.start(1)

func set_sfx_volume(volume, test = false):
	SfxVolume = volume
	var dbVolume = convert_volume_to_db_volume(SfxVolume)
	print("SfxVolume dbVolume " + str(dbVolume))

	if test:
		# Test the sound
		var sfxPlayer = get_node("SfxAudioStreamPlayer")
		sfxPlayer.volume_db = dbVolume
		if !sfxPlayer.playing:
			sfxPlayer.play()

	# Save setting to config after a moment
	var timer = get_node("SettingsDebouncingTimer")
	if timer:
		timer.start(1)

func _on_settings_debouncing_timer_timeout():
	print("Saving settings.")
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		config.set_value("Options", "volume", Volume)
		config.set_value("Options", "sfx_volume", SfxVolume)
		config.save("user://settings.cfg")

func toggle_mouse(show):
	if show:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func any_controller_input():
	return Input.is_action_pressed("AnyControllerInput")

func any_keyboard_and_mouse_input():
	return Input.is_action_pressed("Shoot")
