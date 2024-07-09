extends Node2D
class_name health_component

@export var max_health = 10

signal health_changed
signal died

var current_health

# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func damage(damage):	
	change_health(-damage)

func change_health(delta):
	var previousHealth = current_health
	current_health = clampi((current_health + delta), 0, max_health)
	var health_update = HealthUpdate.new()
	health_update.previous_health = previousHealth
	health_update.current_health = current_health
	health_update.max_health = max_health
	health_update.health_percent = current_health_percent()
	health_changed.emit(health_update)
	if current_health <= 0:
		died.emit()

func current_health_percent():
	return 0 if current_health <= 0 else (current_health as float / max_health as float)
