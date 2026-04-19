extends CharacterBody2D

@export var max_speed := 1200.0
@onready var direction := max_speed

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
	if sprite.frame == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		

func _on_smushed_area_entered(area: Area2D) -> void:
	if area == smusher:
		direction = 0
		
		player.velocity.y *= -1
		
		sprite.play('dead')
		
		collider.set_deferred('disabled', true)
		killer.set_deferred('monitorable', true)
		smushed.set_deferred('monitoring', false)
		
		await get_tree().create_timer(1.0).timeout
		
		queue_free()

func _on_killer_area_entered(area: Area2D) -> void:
	if area == killed:
		camera.follow_player = false
		player.is_alive = false
		
		await get_tree().create_timer(0.5).timeout
		
		player.collider.set_deferred('disabled', true)
		player.killed.set_deferred('monitoring', true)
		player.smusher.set_deferred('monitorable', false)
		
		player.velocity.y = player.jump_height
		
		await get_tree().create_timer(2.0).timeout
		
		player.queue_free()
