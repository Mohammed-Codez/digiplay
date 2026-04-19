extends CharacterBody2D

# editables
@export var max_speed := 1600.0
@export_enum('Alive', 'Shelled', 'Moving', 'Dead') var state := 'Alive'

@onready var prev_state := state

@onready var direction := max_speed

# inner nodes
@onready var sprite := $AnimatedSprite2D
@onready var collider := $CollisionShape2D

@onready var smushed := $SmushedArea
@onready var killer := $KillerArea

@onready var shelled_timer := $ShelledTimer
@onready var moving_timer := $MovingTimer

# player
@onready var player := $'..'/Player
@onready var smusher := $'..'/Player/SmusherArea
@onready var killed := $'..'/Player/KilledArea

@onready var camera := $'..'/Camera2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if state == 'Alive':
		if is_on_wall():
			direction *= -1
		
		velocity.x = direction * delta
		
	elif state == 'Shelled':
		velocity.x = 0
		
	elif state == 'Moving':
		if is_on_wall():
			direction *= -1
			
		velocity.x = 5 * direction * delta
	
	move_and_slide()

func _process(delta: float) -> void:
	if velocity.x != 0:
		if abs(velocity.x) != velocity.x:
			sprite.flip_h = true
		if abs(velocity.x) == velocity.x:
			sprite.flip_h = false
			
	if state != prev_state:
		if state == 'Alive':
			killer.set_deferred('monitoring', true)
			smushed.set_deferred('monitoring', true)
			
			sprite.play('walk')
			
		elif state == 'Shelled':
			killer.set_deferred('monitoring', false)
			
			player.velocity.y *= -0.7
			
			sprite.play('shell')
			
			if shelled_timer.is_stopped():
				shelled_timer.start()
				
		elif state == 'Moving':
			killer.set_deferred('monitoring', true)
			
			player.velocity.y *= -0.7
			
			sprite.play('shell')
		
		if state == 'Moving':
			shelled_timer.stop()
			
	if state == 'Shelled' and shelled_timer.time_left < 3:
		sprite.play("wiggling")
		
	prev_state = state

func _on_smushed_area_entered(area: Area2D) -> void:
	if area == smusher and\
	((abs(player.velocity.y) == player.velocity.y) and player.velocity.y != 0):
		if state == 'Alive':
			state = 'Shelled'
			
		elif state == 'Shelled' and moving_timer.is_stopped():
			state = 'Moving'
			
		elif state == 'Moving':
			state = 'Shelled'

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

func _on_shelled_timer_timeout() -> void:
	if state == 'Shelled':
		state = 'Alive'
