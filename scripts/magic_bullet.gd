extends Area2D
class_name magic_bullet

const Speed = 3.0

@export var Velocity : Vector2 = Vector2.ZERO
@export var Type : Constants.ItemType = Constants.ItemType.GreenStaff
@export var FriendlyFire : bool

@onready var animatedSprite2D = $AnimatedSprite2D

func _ready():
	animatedSprite2D.frame = int(Type)


func _process(delta):
	pass

func _physics_process(delta):
	translate(Velocity)

func _on_lifespan_timer_timeout():
	print("Bullet is too old")
	queue_free()
