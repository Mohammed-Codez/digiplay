extends CharacterBody2D

@export var max_speed := 1200.0
@onready var direction := max_speed
@export_enum('Alive', 'Shelled', 'Dead') var state := 'Alive'

@onready var sprite := $AnimatedSprite2D
@onready var collider := $CollisionShape2D

@onready var smushed := $SmushedArea
@onready var killer := $KillerArea

# player
@onready var player := $'..'/Player
@onready var smusher := $'..'/Player/SmusherArea
@onready var killed := $'..'/Player/KilledArea

@onready var camera := $'..'/Camera2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_wall():
		direction *= -1
		
	velocity.x = direction * delta
	
	move_and_slide()

func _process(delta: float) -> void:
	if velocity.x != 0:
		if abs(velocity.x) != velocity.x:
			sprite.flip_h = true
		if abs(velocity.x) == velocity.x:
			sprite.flip_h = false

func _on_smushed_area_entered(area: Area2D) -> void:
	if area == smusher and\
	(abs(player.velocity.y) == player.velocity.y) and player.velocity.y != 0:
		direction = 0
		
		killer.set_deferred('monitoring', false)
		smushed.set_deferred('monitoring', false)
		
		player.velocity.y *= -0.7
		velocity.y = -100
		
		velocity.x = velocity.x - player.velocity.x
		
		sprite.play('shell')

func _on_killer_area_entered(area: Area2D) -> void:
	if area == killed and player.is_alive:
		camera.follow_player = false
		player.is_alive = false
		
		await get_tree().create_timer(0.5).timeout
		
		player.collider.set_deferred('disabled', true)
		player.killed.set_deferred('monitoring', true)
		player.smusher.set_deferred('monitorable', false)
		
		player.velocity.y = player.jump_height
		
		await get_tree().create_timer(2.0).timeout
		
		player.queue_free()
