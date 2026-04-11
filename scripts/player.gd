extends CharacterBody2D

@export var max_speed := 1600.0
@export var jump_height := -360.0

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_height

	var direction := Input.get_axis("move_left", "move_right")
	
	velocity.x += direction * max_speed * delta 
	velocity.x *= 0.9

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
