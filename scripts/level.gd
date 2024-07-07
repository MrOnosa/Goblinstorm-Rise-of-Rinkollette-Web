extends Node2D

var global : gm
@export var GreenMobScene : PackedScene
@export var PinkMobScene : PackedScene
@export var PickableStaffScene : PackedScene
@export var CurrentStage : int = 0
var Stages : Array = []

var _stats : Stats

@onready var _waveCountLabel = $CanvasLayer/WaveLabel
@onready var _tutorialLabel = $CanvasLayer/Tutorial
@onready var _witch = $Witch

func _ready():
	_stats = Stats.new()
	global = get_node("/root/GM") as gm
	var audioPlayer = global.get_node("AudioStreamPlayer")
	audioPlayer.stop()
	audioPlayer.stream = load("res://assets/music/Game_Jam_Rise_of_Rinkollette_Main_Song_trimmed_normalized.mp3")
	audioPlayer.play()

	# Tutorial logic
	if not global.EverGotPastWaveOne:
		# This one needs more lessons...
		global.EverHeldItem = false
		global.EverHeldCorrectItem = false
		_tutorialLabel.visible = true

	if global.GoblinMode:
		global.EverGotPastWaveOne = false
		_tutorialLabel.visible = true

	get_node("CanvasLayer/GoblinModeLabel").visible = global.GoblinMode

	if global.GoblinMode:
		 #One thousand years ago...
			  #Goblins ruled the scene...
			 #There was no stopping the goblins...
			 #The goblins gonna getcha...
		get_node("CanvasLayer/GoblinModeLabel").visible = true
		Stages = [{'TotalGreenGoblins': 2, 'TotalPinkGoblins': 2}]
	else:
		get_node("CanvasLayer/GoblinModeLabel").visible = false
		Stages = [{'TotalGreenGoblins': 0, 'TotalPinkGoblins': 3},
			{'TotalGreenGoblins': 3, 'TotalPinkGoblins': 0},
			{'TotalGreenGoblins': 2, 'TotalPinkGoblins': 2},
			{'TotalGreenGoblins': 10, 'TotalPinkGoblins': 10}]

func _process(delta):
	_stats.SurvivalTime += delta

	# Tutorial logic
	if global.EverGotPastWaveOne:
		_tutorialLabel.visible = false
	elif global.EverKilledGoblin:
		if global.GoblinMode:
			_tutorialLabel.text = "GOBLIN MODE: The goblins never end!!"
		else:
				_tutorialLabel.text = "Defeat all goblins"
	elif global.EverHeldCorrectItem:
		_tutorialLabel.text = "Shoot the goblins"
	elif global.EverHeldItem:
		_tutorialLabel.text = "Wrong staff!"
	else:
		_tutorialLabel.text = "Grab a staff!"

	if Input.is_action_pressed("C_Pause"):
		get_tree().paused = true
		get_node("Pause/CanvasLayer").show()
		get_node("Pause/CanvasLayer/Panel/VBoxContainer/ResumeButton").grab_focus()

func _physics_process(delta):
	for child in get_children():
		if child is green_goblin:
			var g = child as green_goblin
			g.move_towards_player(_witch.position, delta)

func _on_mob_spawn_timer_timeout():
	var goblinBag = []
	var currentStage = null
	if Stages.size() > CurrentStage:
		currentStage = Stages[CurrentStage]
	if currentStage == null: return

	for _i in range(currentStage["TotalGreenGoblins"]):
		goblinBag.append('G')

	for _i in range(currentStage["TotalPinkGoblins"]):
		goblinBag.append('P')

	if goblinBag.count == 0: return

	var winner = goblinBag[randi() % goblinBag.size()]
	print("Winner "+winner)
	var mob = null

	if winner == 'G':
		currentStage["TotalGreenGoblins"] -= 1
		mob = GreenMobScene.instance()
	elif winner == 'P':
		currentStage["TotalPinkGoblins"] -= 1
		mob = PinkMobScene.instance()

	var mobSpawnLocation = get_node("Witch/MobPath2D/MobSpawnLocation")
	mobSpawnLocation.offset = randf()

	# Set the mob's position to a random location
	mob.global_position = mobSpawnLocation.global_position
	mob.connect("Dead", self, "_mob_died_handler")

	# Spawn the mob by adding it to the Main scene
	add_child(mob)

func _mob_died_handler(type):
	global.EverKilledGoblin = true
	match type:
		Constants.ItemType.GreenStaff:
			_stats.TotalDeadGreenGoblins += 1
		Constants.ItemType.PinkStaff:
			_stats.TotalDeadPinkGoblins += 1

	# Short pause to let things settle. 
	await get_tree().create_timer(1.0).timeout

	var currentStage = null
	if CurrentStage < Stages.size():
		currentStage = Stages[CurrentStage]

	if currentStage == null or (currentStage["TotalPinkGoblins"] + currentStage["TotalGreenGoblins"] > 0): 
		return

	# Check if any goblins are still on the screen
	var allGoblins : Array[green_goblin] = []
	for child in get_children():
		if child is green_goblin:
			allGoblins.push_back(child as green_goblin)
	if allGoblins.size() == 0:
		# The last mob died. New wave!
		CurrentStage += 1
		global.EverGotPastWaveOne = true
		_stats.Wave = CurrentStage + 1

		if global.GoblinMode:
			# Goblins gonna goblin forever...
			var total = floor(pow(CurrentStage, 1.5) + 4.0)
			var green = randi() % total
			Stages.append({
				'TotalGreenGoblins': green,
				'TotalPinkGoblins': total - green
			})
		elif CurrentStage >= Stages.size():
			# Victory!!!
			global.GameStats = _stats
			get_tree().change_scene_to_file("res://scenes/victory.tscn")
			return

		_waveCountLabel.text = str(CurrentStage + 1)

func _on_staff_spawn_timer_timeout():
	var allItems : Array[item] = []
	for child in get_children():
		if child is item:
			allItems.push_back(child)
	if allItems.size() < 4:
		var staff = PickableStaffScene.instance()
		var spawnLocation = get_node("Witch/StaffPath2D/StaffPathLocation")
		spawnLocation.offset = randf()

		# Set the mob's position to a random location.
		staff.global_position = spawnLocation.global_position
		if randi() % 2 == 0:
			staff.typ = Constants.ItemType.GreenStaff
		else:
			staff.typ = Constants.ItemType.PinkStaff
			
		# Spawn the mob by adding it to the Main scene.
		add_child(staff)

func _on_witch_health_changed(healthUpdate):
	var lifeBar = get_node("CanvasLayer/LifeBar")
	lifeBar.paint(healthUpdate.currentHealth)

func _on_witch_item_changed(itemType):
	global.EverHeldItem = true
	var anyGoblinsWeakToItemType = false
	for child in get_children():
		if child is green_goblin:
			var g = child as green_goblin
			anyGoblinsWeakToItemType |= g.WeakToType == itemType
	
	if anyGoblinsWeakToItemType:
		global.EverHeldCorrectItem = true


func _on_witch_died():
	#TODO: Death animation
	global.GameStats = _stats
	get_tree().change_scene("res://scenes/game_over.tscn")
