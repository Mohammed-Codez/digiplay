extends CharacterBody2D

@export var max_speed := 1600.0
@export var jump_height := -360.0

@onready var sprite := $AnimatedSprite2D
@onready var coyote := $CoyoteTimer

func _physics_process(delta: float) -> void:
	var direction := 0.0
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.x *= 0.9
		coyote.start()
		
	direction = Input.get_axis("move_left", "move_right")
	velocity.x *= 0.85

	if Input.is_action_just_pressed("jump") and\
	(is_on_floor() or not coyote.is_stopped()):
		velocity.y = jump_height

	velocity.x += direction * max_speed * delta 

	move_and_slide()

func _process(delta: float) -> void:
	if not is_on_floor():
		sprite.play('jump')
	elif abs(velocity.x) >= 10:
		sprite.play('walk')
	else:
		sprite.play('idle')
		
	if abs(velocity.x) != velocity.x:
		sprite.flip_h = true
		
	if abs(velocity.x) == velocity.x:
		sprite.flip_h = false
