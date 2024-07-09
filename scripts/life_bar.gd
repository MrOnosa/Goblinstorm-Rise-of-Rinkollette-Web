extends Node2D

const OFFSET = 34
@export var HeartScene : PackedScene

var _hp
var _wiggleCount = 0.05

func _ready() -> void:
	paint(10)

func _process(delta):
	_wiggleCount -= delta
	if _wiggleCount < 0:
		_wiggleCount = 0.05
		if _hp < 5:
			var x = 0
			for child in get_children():
				child.position = Vector2(x + randi_range(-1, 1), randi_range(-1, 1))
				x += OFFSET

func paint(hp):
	_hp = hp
	print("Setting life bar to " + str(hp))
	for i in range(5):
		for child in get_children():
			child.queue_free()

	var x = 0
	var odd = hp % 2 == 1
	for i in range(int(hp / 2)):
		var heart = HeartScene.instantiate()
		heart.position = Vector2(x, 0)
		x += OFFSET
		add_child(heart)

	if odd:
		var heart = HeartScene.instantiate()
		heart.position = Vector2(x, 0)
		heart.frame = 1
		add_child(heart)
