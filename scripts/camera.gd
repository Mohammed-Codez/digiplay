extends Camera2D

@onready var player := $'..'/Player
@export var follow_player := true

func _process(delta: float) -> void:
	if follow_player:
		position.x = player.position.x
