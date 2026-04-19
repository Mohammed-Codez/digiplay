extends CharacterBody2D

@export var max_speed := 1600.0
@export var jump_height := -350.0

@onready var sprite := $AnimatedSprite2D

@onready var collider := $CollisionShape2D
@onready var smusher := $SmusherArea
@onready var killed := $KilledArea

@onready var coyote := $CoyoteTimer
@onready var up_coyote := $UpCoyoteTimer
@onready var was_on_floor := is_on_floor()

@export var is_alive := true

func _physics_process(delta: float) -> void:
	var direction := 0.0
	
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		direction = 0.3 * Input.get_axis("move_left", "move_right")
		
		if was_on_floor:
			coyote.start()
			up_coyote.start()
			
		velocity.x *= 0.9999
			
	if is_on_floor() or not up_coyote.is_stopped():
		direction = Input.get_axis("move_left", "move_right")
		velocity.x *= 0.9
		
	if is_on_floor() or not coyote.is_stopped():
		if Input.is_action_just_pressed("jump") and is_alive:
			position.y += -velocity.y * delta
			velocity.y = jump_height

	velocity.x += direction * max_speed * delta * int(is_alive)
	
	was_on_floor = is_on_floor()

	move_and_slide()

func _process(delta: float) -> void:
	if not is_on_floor():
		sprite.play('jump')
	elif abs(velocity.x) >= 10:
		sprite.play('walk')
		sprite.speed_scale = velocity.x / 50
	else:
		sprite.play('idle')
		
	if abs(velocity.x) != velocity.x:
		sprite.flip_h = true
		
	if abs(velocity.x) == velocity.x and velocity.x != 0:
		sprite.flip_h = false

	sprite.scale.y = clamp(1 + velocity.y / 1000, 0.75, 1.5)
	sprite.scale.x = 1 / sprite.scale.y
	
	sprite.position.y = sprite.scale.y / 2

	if not is_alive:
		sprite.play('die')
