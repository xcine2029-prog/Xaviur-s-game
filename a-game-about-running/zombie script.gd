extends CharacterBody2D

@onready var pp = $"../human" 
@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var scary_music: AudioStreamPlayer2D = $"AudioStreamPlayer2D"


var SPEED = 405.0
const JUMP_VELOCITY = -50.0
const TURN_DELAY = 0.5

var turn_timer = 0.0
var current_dir = 0 

func _physics_process(delta: float) -> void:
	var player_pos = pp.global_position.x
	var player_posy = pp.global_position.y
	var my_pos = global_position.x
	var my_posy = global_position.y
	var distance = player_pos - my_pos
	var distancey = player_posy - my_posy
	
	if abs(distance) > 200:
		SPEED = 100
	else:
		SPEED = 90
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	var intended_dir = 0
	if abs(distance) < 500:
		intended_dir = 1 if distance > 0 else -1
	if abs(distance) < 15 and abs(distancey) < 15 :
		var _reload = get_tree().reload_current_scene()
		
		
	if intended_dir != current_dir:
		turn_timer += delta
		if turn_timer >= TURN_DELAY:
			current_dir = intended_dir
			turn_timer = 0.0
	else:
		turn_timer = 0.0 

	if current_dir == 1 and not is_on_floor():
		velocity.x = SPEED / 1
		animated_sprite.flip_h = false
	elif current_dir == -1 and not is_on_floor():
		velocity.x = -SPEED / 1
		animated_sprite.flip_h = true
	elif current_dir == 1:
		velocity.x = SPEED
		animated_sprite.flip_h = false
	elif current_dir == -1:
		velocity.x = -SPEED
		animated_sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var jumping = 0
	if  abs(distancey) > 15 and abs(distance) < 500 and is_on_floor() and jumping == 0:
		jumping = 1
		await get_tree().create_timer(.05).timeout
		velocity.y = -300
		jumping = 0
	# Animation Logic
	if is_on_wall():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("climb")
	else:
		if velocity.x != 0 and is_on_floor():
			animated_sprite.speed_scale = 1.5
			animated_sprite.play("run")
		else:
			if not is_on_floor() and velocity.x != 0:
				animated_sprite.play("air run")
			else:
					animated_sprite.speed_scale = 1
					animated_sprite.play("idle") 
	
	move_and_slide()
	
func _on_chase_body_entered(body: Node2D) -> void:
	global_position = Vector2(9126, 562) 
