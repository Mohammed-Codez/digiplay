extends CharacterBody2D

# editables
@export var max_speed := 1600.0
@export_enum('Alive', 'Dead') var state := 'Alive'

@onready var prev_state := state

@onready var direction := max_speed

# inner nodes
@onready var sprite := $AnimatedSprite2D
@onready var collider := $CollisionShape2D

@onready var smushed := $SmushedArea
@onready var killer := $KillerArea

@onready var death_timer := $DeathTimer

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
	if sprite.frame == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	if state == 'Dead' and state != prev_state:
		direction = 0
	
		collider.set_deferred('disabled', true)
		killer.set_deferred('monitoring', false)
		smushed.set_deferred('monitoring', false)
		
		player.velocity.y *= -0.7
		velocity.y = -100
		velocity.x = velocity.x - player.velocity.x
		
		sprite.play('dead')
		
		death_timer.start()
		
	if death_timer.is_stopped() and state == 'Dead':
		queue_free()
		
	prev_state = state

func _on_smushed_area_entered(area: Area2D) -> void:
	if area == smusher and\
	(abs(player.velocity.y) == player.velocity.y) and player.velocity.y != 0:
		state = 'Dead'

func _on_killer_area_entered(area: Area2D) -> void:
	if area == killed and player.is_alive:
		camera.follow_player = false
		player.is_alive = false
		
		await get_tree().create_timer(0.5).timeout
		
		player.collider.set_deferred('disabled', true)
		player.killed.set_deferred('monitoring', false)
		player.smusher.set_deferred('monitorable', false)
		
		player.velocity.y = player.jump_height
		
		await get_tree().create_timer(2.0).timeout
		
		player.queue_free()
