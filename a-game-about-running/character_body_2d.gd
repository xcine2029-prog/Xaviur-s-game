extends CharacterBody2D

@onready var emitter : GPUParticles2D = $"run effect"

@onready var emitter2 : GPUParticles2D = $"jump effect"

@onready var emitter3: GPUParticles2D = $"double jump effect"

@onready var camera: Camera2D = $"player 1 cam"

@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"

@onready var hitbox_base: CollisionShape2D = $"base"

@onready var hitbox_slide: CollisionShape2D = $"slide"

@onready var hitbox_left: Area2D = $"left hitbox"

@onready var hitbox_right: Area2D = $"right hitbox"

@onready var hitsound: AudioStreamPlayer2D = $"hit sound"



var dash_cooldown = 0

var waiting = 0

var crouch_cam_decrease_rate = 100

var crouching = 0

var sprinting = 0

var stamina = 100

var stamina_decrease = 1

var last_direction2 = 0

var last_direction = 0

var last_direction3 = 0

var last_directionv = 0

var SPEED = 100.0

const JUMP_VELOCITY = -400.0

var SLIDE_VELOCITY = 300.0

var Double_Jump =1

func DEATH():
	get_tree().change_scene_to_file("res://death.tscn")

func sprint_delay():
  
	await get_tree().create_timer(1.5).timeout

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
		
# sprint effect.
	if Input.is_action_pressed("sprint") and velocity.length() > .1 and is_on_floor() and crouching <= 0:
		emitter.emitting = true
		print("effect")
	else:
		emitter.emitting = false
		
		
		
	if Input.is_action_pressed("left"):
		last_direction = true
		last_direction2 = 200
		last_direction3 = -1
	
	if Input.is_action_pressed("right"):
		last_direction = false
		last_direction2 = -200
		last_direction3 = 1
		
	if velocity.x > 0:
		last_directionv = true
	else:
		if velocity.x < 0:
			last_directionv = false
	
	if Input.is_action_pressed("sprint") and crouching <= 0 and stamina >= 1:
		sprinting = 1
		stamina -= delta * stamina_decrease
		SPEED = 300 
		animated_sprite.speed_scale = 1
	else:
		if stamina < 100:
			sprint_delay()
			stamina += delta * stamina_decrease
		if Input.is_action_pressed("down") and sprinting <= 0 and is_on_floor() and waiting == 0:
			crouching = 1
			SPEED = 80
			animated_sprite.speed_scale = 1.5
			hitbox_slide.disabled = false
			hitbox_base.disabled = true
			camera.offset.y += delta * crouch_cam_decrease_rate
			if camera.offset.y >= 20:
				crouch_cam_decrease_rate = 0
		else:
			if camera.offset.y >= 0:
				crouch_cam_decrease_rate = 100
				camera.offset.y -= delta * crouch_cam_decrease_rate
				
				
			crouching = 0
			sprinting = 0
			SPEED = 100
			animated_sprite.speed_scale = 1
			hitbox_slide.disabled = true
			hitbox_base.disabled = false
	
	if is_on_floor():
		Double_Jump = 0
		
			
	# Handle jump.
	if Input.is_action_pressed("up") and is_on_wall() and not is_on_floor() and waiting == 0:
		var wall_normal = get_wall_normal()
		velocity.x = wall_normal.x * 280
		animated_sprite.play("flip") 
		velocity.y = -400
		animated_sprite.flip_h = last_directionv
		emitter2.emitting = true
	else:
		if Input.is_action_just_pressed("up") and is_on_floor() and waiting == 0:
			velocity.y = JUMP_VELOCITY 
			Double_Jump = Double_Jump + 1
			emitter2.emitting = true

	if Input.is_action_just_pressed("up") and not is_on_floor() and Double_Jump >= 1 and not is_on_wall() and waiting == 0:
		velocity.y = JUMP_VELOCITY 
		Double_Jump = 0
		emitter3.emitting = true
	
	
	
	if Input.is_action_just_pressed("melee") and waiting == 0 and is_on_floor():
		if last_direction2 == 200:
			waiting = 1
			animated_sprite.play("punch")
			await get_tree().create_timer(0.1).timeout
			hitbox_left.monitoring = true
			await get_tree().create_timer(0.1).timeout
			hitbox_left.monitoring = false
			await get_tree().create_timer(.2).timeout
			waiting = 0
		else:
			if last_direction2 == -200 and waiting == 0:
				waiting = 1
				animated_sprite.play("punch")
				await get_tree().create_timer(0.1).timeout
				hitbox_right.monitoring = true
				await get_tree().create_timer(0.1).timeout
				hitbox_right.monitoring = false
				await get_tree().create_timer(.2).timeout
				waiting = 0
	

	
	
		
	
	var direction := Input.get_axis("left", "right")
	if is_on_floor() and not is_on_wall() and direction and sprinting <= 0 and crouching <= 0 and not waiting == 1:
		velocity.x = direction * SPEED
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0
	else:
		if is_on_floor() and is_on_wall() and direction and sprinting <= 0 and crouching <= 0 and not waiting == 1:
			velocity.x = direction * SPEED
			animated_sprite.play("wall run")
			animated_sprite.flip_h = direction < 0
		else:
			if is_on_floor() and is_on_wall() and direction and sprinting > 0 and crouching <= 0 and not waiting == 1:
				velocity.x = direction * SPEED
				animated_sprite.play("wall run")
				animated_sprite.flip_h = direction < 0
			else:
				if is_on_floor() and direction and sprinting > 0 and crouching <= 0 and not waiting == 1:
					velocity.x = direction * SPEED
					animated_sprite.play("sprint")
					animated_sprite.flip_h = direction < 0
				else:
					if is_on_floor() and direction and sprinting <= 0 and crouching > 0 and not waiting == 1:
						velocity.x = direction * SPEED
						animated_sprite.play("slide")
						animated_sprite.flip_h = direction < 0
					else:
						if not is_on_floor() and velocity.y < 0 and waiting == 0:
							animated_sprite.play("air idle")
						else:
							if not is_on_floor() and velocity.y > 0 and waiting == 0:
								animated_sprite.play("fall")
							else:
								if Input.is_action_pressed("down") and is_on_floor() and velocity.x <= .1 and velocity.x >= -.1 and not waiting == 1:
									animated_sprite.play("crouch")
								else:
									if waiting == 1:
										velocity.x = move_toward(velocity.x, 0, SPEED) 
										animated_sprite.flip_h = last_direction
									elif waiting == 0:
										animated_sprite.play("idle")
										velocity.x = move_toward(velocity.x, 0, SPEED) 
										animated_sprite.flip_h = last_direction
				
	
	
	
	if Input.is_action_just_pressed("sandy") and dash_cooldown == 0:
		velocity.x = (velocity.x * 1.5 )
		velocity.y = JUMP_VELOCITY / 2
		animated_sprite.flip_h = direction < 0
		dash_cooldown = 1
		animated_sprite.play("dash")
		waiting = 1
		await get_tree().create_timer(.3).timeout
		waiting = 0
		await get_tree().create_timer(1).timeout
		dash_cooldown = 0

	
	
	
	
	
	move_and_slide()

var l_launch_force = Vector2(-200000, -100000)
var r_launch_force = Vector2(200000, -100000)
	
func _on_left_hitbox_body_entered(body: Node2D) -> void:
	print("left hit")
	if body is RigidBody2D:
		body.apply_impulse(l_launch_force)
		hitsound.play()



func _on_right_hitbox_body_entered(body: Node2D) -> void:
	print("right hit")
	if body is RigidBody2D:
		body.apply_impulse(r_launch_force)
		hitsound.play()
