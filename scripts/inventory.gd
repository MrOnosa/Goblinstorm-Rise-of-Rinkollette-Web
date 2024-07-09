extends TextureRect

@onready var animated_sprite_2d = $AnimatedSprite2D


func _ready() -> void:
	animated_sprite_2d.frame = int(Constants.ItemType.None)

func _process(delta) -> void:
	pass

func _on_witch_item_changed(itemType):
	animated_sprite_2d.frame = int(itemType)
