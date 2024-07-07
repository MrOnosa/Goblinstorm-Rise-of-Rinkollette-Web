extends Area2D
class_name item

@export var Type = Constants.ItemType.GreenStaff

var _animatedSprite2D

func _ready() -> void:
	_animatedSprite2D = get_node("AnimatedSprite2D")
	_animatedSprite2D.frame = int(Type)
	
func _process(delta):
	pass

func _on_life_timer_timeout() -> void:
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	var lifeTimer = get_node("LifeTimer")
	lifeTimer.start()
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	var lifeTimer = get_node("LifeTimer")
	lifeTimer.stop()
