extends TextureRect

var _animatedSprite2D

func _ready() -> void:
	_animatedSprite2D = get_node("AnimatedSprite2D")
	_animatedSprite2D.frame = int(Constants.ItemType.None)

func _process(delta) -> void:
	pass

func _on_witch_item_changed(itemType):
	_animatedSprite2D.frame = int(itemType)
