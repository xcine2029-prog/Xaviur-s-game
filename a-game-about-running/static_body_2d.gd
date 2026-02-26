extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $"Sprite2D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	animated_sprite.play("new_animation")
	
var speed = 100
 



func _on_wait_1_timeout() -> void:
	print("get ready")
	
	
	
	
