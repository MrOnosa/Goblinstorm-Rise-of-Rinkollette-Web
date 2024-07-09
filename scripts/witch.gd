extends CharacterBody2D

var global: gm

signal ItemChanged(itemType: Constants.ItemType)
signal HealthChanged(healthUpdate: HealthUpdate)
signal Died

var Speed = 100.0
var shooting = false
var Invincible = false

@export var InventorySlot1 : Constants.ItemType = Constants.ItemType.None

@onready var _animatedSprite2D = $"AnimatedSprite2D"
@onready var _timer = $"ShootCooldownTimer"
@onready var _invincibilityTimer = $"InvincibilityTimer"
@onready var _camera = $"Camera2D"
@onready var _healthComponent : health_component = $"HealthComponent"

func _ready():
	global = get_node("/root/GM")
	_toggle_invincible_shader(false)
	
func _process(delta):
	var twin = Input.get_vector("TwinStickShootLeft", "TwinStickShootRight", "TwinStickShootUp", "TwinStickShootDown")
	if (Input.is_action_pressed("Shoot")):
		Shoot()
	elif twin != Vector2.ZERO:
		TwinStickShoot()

func _physics_process(delta):
	var v_local = velocity

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if global.UsingController:
		direction = Input.get_vector("C_Left", "C_Right", "C_Up", "C_Down")
	if direction != Vector2.ZERO:
		v_local.x = direction.x * Speed
		v_local.y = direction.y * Speed
	else:
		v_local.x = move_toward(velocity.x, 0.0, Speed)
		v_local.y = move_toward(velocity.y, 0.0, Speed)

	velocity = v_local
	
	# Determine if the witch is moving or idle and set the appropriate animation.
	if velocity != Vector2.ZERO:
		# Run slower if they are moving slower.
		_animatedSprite2D.speed_scale = v_local.length() / Speed
		if _animatedSprite2D.animation != "run":
			_animatedSprite2D.play("run")
	else:
		# Always idle at full speed.
		_animatedSprite2D.speed_scale = 1
		if _animatedSprite2D.animation != "idle":
			_animatedSprite2D.play("idle")
	
	if v_local.x < 0:
		_animatedSprite2D.scale = Vector2(-1, 1)
	else:
		_animatedSprite2D.scale = Vector2(1, 1)

	move_and_slide()

func Shoot():
	if not shooting and InventorySlot1 != Constants.ItemType.None:
		print("Boom!")
		shooting = true
		_timer.start()
		var inst = InitMagicBullet()
		
		# Calc magic bullet v_local for a mouse
		var mousePos = _camera.get_global_mouse_position() 
		
		# Calculate the direction to the mouse from the bullet 
		var direction = (mousePos - inst.global_position).normalized() 
		
		var v_local = direction * magic_bullet.Speed
		inst.Velocity = v_local
		add_sibling(inst)

func InitMagicBullet():
	var scene = load("res://scenes/magic_bullet.tscn")
	var inst = scene.instantiate()
	inst.FriendlyFire = true
	inst.global_position = global_position
	inst.Type = InventorySlot1

	if InventorySlot1 == Constants.ItemType.GreenStaff:
		var sfx = get_node("ShootGreenAudioStreamPlayer2D")
		sfx.volume_db = global.convert_volume_to_db_volume(global.SfxVolume)
		sfx.play()
	elif InventorySlot1 == Constants.ItemType.PinkStaff:
		var sfx = get_node("ShootPinkAudioStreamPlayer2D")
		sfx.volume_db = global.convert_volume_to_db_volume(global.SfxVolume)
		sfx.play()

	return inst

func TwinStickShoot():
	if not shooting and InventorySlot1 != Constants.ItemType.None:
		print("Twin Stick Boom!")
		shooting = true
		_timer.start()
		var inst = InitMagicBullet()
		
		# Calc magic bullet v_local for twin stick
		var direction = Input.get_vector("TwinStickShootLeft", "TwinStickShootRight", "TwinStickShootUp", "TwinStickShootDown").normalized()
		
		var v_local = direction * magic_bullet.Speed
		inst.Velocity = v_local
		add_sibling(inst)

func _on_shoot_cooldown_timer_timeout():
	shooting = false
	
func _on_health_component_health_changed(healthUpdate : HealthUpdate):
	if healthUpdate.current_health > 0:
		var sfx = get_node("HurtAudioStreamPlayer2D")
		sfx.volume_db = global.convert_volume_to_db_volume(global.SfxVolume)
		sfx.play()
	
	HealthChanged.emit(healthUpdate)
	
func _on_health_component_died():
	var sfx = get_node("DiedAudioStreamPlayer2D")
	sfx.volume_db = global.convert_volume_to_db_volume(global.SfxVolume)
	sfx.play()
	visible = false
	
	# Wait for death sound to play
	await get_tree().create_timer(sfx.stream.get_length()).timeout
	
	Died.emit()

func _on_hit_box_area_2d_area_entered(area):
	if not Invincible:
		if area is green_goblin:
			TakeDamageRoutine(2)
		elif area is magic_bullet:
			if not area.FriendlyFire:
				TakeDamageRoutine(1)
	
	if area is item:
		InventorySlot1 = area.Type
		area.queue_free()
		ItemChanged.emit(InventorySlot1)
		
		var sfx = get_node("PickUpStaffAudioStreamPlayer2D")
		sfx.volume_db = global.convert_volume_to_db_volume(global.SfxVolume)
		sfx.play()

func TakeDamageRoutine(damage):
	_invincibilityTimer.start()
	_healthComponent.damage(damage)
	Invincible = true
	_toggle_invincible_shader(true)
	
func _on_invincibility_timer_timeout():
	Invincible = false
	_toggle_invincible_shader(false)
		
#  for the shader, you can use:
func _toggle_invincible_shader(active):
	var sprite = $"AnimatedSprite2D"
	sprite.material.set("shader_parameter/invincible", active)

