extends Area2D
class_name green_goblin

var global = null

@export var Speed: float = 1.0
@export var BulletFireWaitTime: float = 1.0
@export var BulletFireVariance: float = 0.5
@export var WeakToType: Constants.ItemType = Constants.ItemType.GreenStaff
signal Dead(type: Constants.ItemType)

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var shoot_bullet_timer = $ShootBulletTimer
@onready var hurt_timer = $HurtTimer


const BULLET_2 = preload("res://scenes/bullet2.tscn")


func _ready() -> void:
	global = get_node("/root/GM")
	
	set_shoot_bullet_timer_wait_time_to_a_random_range()

	var sprite = get_node("AnimatedSprite2D")
	if sprite.material is ShaderMaterial:
		sprite.material = sprite.material.duplicate()

func set_shoot_bullet_timer_wait_time_to_a_random_range() -> void:
	shoot_bullet_timer.wait_time = randf_range(BulletFireWaitTime * BulletFireVariance, BulletFireWaitTime + (BulletFireWaitTime * BulletFireVariance))

func _process(delta):
	pass

func move_towards_player(witchPosition, delta) -> void:
	# Calculate the direction to the player from the goblin 
	var direction = (witchPosition - position).normalized()
	var velocity = direction * Speed
	translate(velocity)

	animated_sprite_2d.scale = Vector2(1 if velocity.x >= 0 else -1, 1)


func _on_area_entered(area: Area2D) -> void:
	if area is magic_bullet:
		var bullet = area as magic_bullet
		if bullet.FriendlyFire:
			bullet.queue_free()
			if bullet.velocity != null:
				position += bullet.velocity

			if bullet.Type == WeakToType:
				health_component.damage(1)
				if hurt_timer.is_stopped():
					var sprite = get_node("AnimatedSprite2D")
					sprite.material.set("hurt", true)
				hurt_timer.start(1)

				var sfx = get_node("HurtAudioStreamPlayer2D")
				sfx.volume_db = global.convert_volume_to_db_volume(global.sfx_volume)
				sfx.play()
			else:
				var sfx = get_node("NotHurtAudioStreamPlayer2D")
				sfx.volume_db = global.convert_volume_to_db_volume(global.sfx_volume)
				sfx.play()

func _on_hurt_timer_timeout() -> void:
	var sprite = get_node("AnimatedSprite2D")
	sprite.material.set("hurt", false)
	hurt_timer.stop()

func _on_health_component_died() -> void:
	var sfx = get_node("DoomDoomDeadosAudioStreamPlayer2D")
	sfx.volume_db = global.convert_volume_to_db_volume(global.sfx_volume)
	sfx.play()
	visible = false
	
	await get_tree().create_timer(sfx.stream.get_length()).timeout

	queue_free()

	emit_signal("Dead", WeakToType)

func _on_shoot_bullet_timer_timeout() -> void:
	if !visible: return # Gobo is deado
	
	set_shoot_bullet_timer_wait_time_to_a_random_range()

	var scene = BULLET_2.instantiate()
	var bullet_spawn_point : Marker2D
	if animated_sprite_2d.scale.x < 0:
		bullet_spawn_point = get_node("BulletSpawnMarker2DLeft")
	else:
		bullet_spawn_point = get_node("BulletSpawnMarker2DRight")

	var inst = scene
	inst.FriendlyFire = false
	if bullet_spawn_point != null && bullet_spawn_point.global_position != null:
		inst.global_position = bullet_spawn_point.global_position
	else:
		inst.global_position = global_position
	
	var level = get_parent()
	var witch = level.find_node("Witch")
	var mouse_pos = witch.global_position

	var direction = (mouse_pos - inst.global_position).normalized()
	inst.velocity = direction * magic_bullet.Speed
	inst.rotation = inst.velocity.angle() + PI

	add_sibling(inst)

	var sfx = get_node("GunShotAudioStreamPlayer2D")
	sfx.volume_db = global.convert_volume_to_db_volume(global.sfx_volume)
	sfx.play()
