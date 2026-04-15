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

@onready var gun_eff: CPUParticles2D = $"shotgun eff"

@onready var gun_eff2: CPUParticles2D = $"shotgun eff2"

@onready var gun_eff3: CPUParticles2D = $"shotgun fall"

@onready var gun_sfx1: AudioStreamPlayer2D = $"reload"

@onready var gun_sfx2: AudioStreamPlayer2D = $"shoot"

@onready var rledge: Area2D = $"r-ledge"

@onready var lledge: Area2D = $"l-ledge"




var dash_cooldown = 0

var waiting = 0

var crouch_cam_decrease_rate = 100

var crouching = 0

var sprinting = 0

var climbing = 0

var stamina = 100

var vault = 0

var stamina_decrease = 1

var last_direction2 = 0

var last_direction = 0

var last_direction3 = 0

var last_directionv = 0

var SPEED = 100.0

const JUMP_VELOCITY = -280.0

var SLIDE_VELOCITY = 300.0

var Double_Jump =1

func DEATH():
	get_tree().change_scene_to_file("res://death.tscn")

func sprint_delay():
  
	await get_tree().create_timer(1.5).timeout

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and vault == 0:
		velocity += get_gravity() * delta
	
	
		
# sprint effect.
	if Input.is_action_pressed("sprint") and velocity.length() > .1 and is_on_floor() and crouching <= 0:
		emitter.emitting = true
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
	
	if Input.is_action_pressed("sprint") and crouching <= 0 and waiting == 0:
		sprinting = 1
		stamina -= delta * stamina_decrease
		SPEED = 250
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
	
		if Input.is_action_just_released("up") and is_on_wall() and not is_on_floor() and waiting == 0:
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * 280
			animated_sprite.play("flip") 
			velocity.y = -400
			animated_sprite.flip_h = last_directionv
			emitter2.emitting = true
			
	
	
	
	
	if Input.is_action_just_pressed("melee") and waiting == 0 and is_on_floor():
			waiting = 1
			animated_sprite.play("shoot")
			gun_sfx1.play()
			await get_tree().create_timer(.77).timeout
			if last_direction2 == 200:
				gun_eff.scale.x = -1
				gun_eff.emitting = true
				gun_eff2.scale.x = -1
				gun_eff2.emitting = true
				hitbox_left.monitoring = true
				gun_eff3.scale.x = -1
				gun_eff3.emitting = true
				gun_sfx2.play()
				await get_tree().create_timer(0.1).timeout
				hitbox_left.monitoring = false
				await get_tree().create_timer(.2).timeout
				waiting = 0
			elif last_direction2 == -200:
				gun_eff.scale.x = 1
				gun_eff.emitting = true
				gun_eff2.scale.x = 1
				gun_eff2.emitting = true
				hitbox_right.monitoring = true
				gun_eff3.scale.x = 1
				gun_eff3.emitting = true
				gun_sfx2.play()
				await get_tree().create_timer(0.1).timeout
				hitbox_right.monitoring = false
				await get_tree().create_timer(.2).timeout
				waiting = 0
			else :
				waiting = 0
	
	
	
		
	
	var direction := Input.get_axis("left", "right")
	if is_on_floor() and not is_on_wall() and direction and sprinting <= 0 and crouching <= 0 and not waiting == 1:
		velocity.x = direction * SPEED
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0
	elif is_on_floor() and is_on_wall() and direction and sprinting <= 0 and crouching <= 0 and not waiting == 1:
		velocity.x = direction * SPEED
		animated_sprite.play("wall run")
		animated_sprite.flip_h = direction < 0
	elif is_on_floor() and is_on_wall() and direction and sprinting <= 0 and crouching <= 0 and not waiting == 1:
		velocity.x = direction * SPEED
		animated_sprite.play("wall run")
		animated_sprite.flip_h = direction < 0
	elif is_on_floor() and direction and sprinting > 0 and crouching <= 0 and not waiting == 1:
		velocity.x = direction * SPEED
		animated_sprite.play("sprint")
		animated_sprite.flip_h = direction < 0
	elif  is_on_floor() and direction and sprinting <= 0 and crouching > 0 and not waiting == 1:
		velocity.x = direction * SPEED
		animated_sprite.play("slide")
		animated_sprite.flip_h = direction < 0
	elif not is_on_floor() and not is_on_wall() and velocity.y < 0 and waiting == 0:
		animated_sprite.play("air idle")
		velocity.x = direction * SPEED/2
	elif not is_on_floor() and velocity.y > 0 and waiting == 0:
		animated_sprite.play("fall")
		velocity.x = direction * SPEED/2
	elif  Input.is_action_pressed("down") and is_on_floor() and velocity.x <= .1 and velocity.x >= -.1 and not waiting == 1:
		animated_sprite.play("crouch")
	elif waiting == 1:
		velocity.x = move_toward(velocity.x, 0, SPEED) 
		animated_sprite.flip_h = last_direction
	elif waiting == 0 and climbing == 0:
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED) 
		animated_sprite.flip_h = last_direction
				
	# Handle jump.
	if Input.is_action_pressed("up") and is_on_wall() and not is_on_floor() and waiting == 0:
		animated_sprite.play("climb") 
		climbing = 1
		velocity.x = direction * SPEED
		velocity.y = -60
		animated_sprite.flip_h = last_direction
		emitter2.emitting = true
	else:
		climbing = 0
		if Input.is_action_just_pressed("up") and is_on_floor() and waiting == 0:
			velocity.y = JUMP_VELOCITY 
			Double_Jump = Double_Jump + 0
			emitter2.emitting = true

	if Input.is_action_just_pressed("up") and not is_on_floor() and Double_Jump == 1 and not is_on_wall() and waiting == 0:
		velocity.y = JUMP_VELOCITY 
		Double_Jump = 0
		emitter3.emitting = true
	
	
	
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
	
	
	if climbing == 1 :
		if last_direction3 == 1 and climbing == 1:
			rledge.monitoring = true
		elif last_direction3 == -1 and climbing == 1:
			lledge.monitoring = true
	else:
		rledge.monitoring = false
		lledge.monitoring = false
	
	
	move_and_slide()

var l_launch_force = Vector2(-200000, -100000)
var r_launch_force = Vector2(200000, -100000)
	
func _on_left_hitbox_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		print("left hit")
		body.apply_impulse(l_launch_force)
		hitsound.play()
	elif body is CharacterBody2D:
		print("left hit")
		hitsound.play()



func _on_right_hitbox_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		print("right hit")
		body.apply_impulse(r_launch_force)
		hitsound.play()
	elif body is CharacterBody2D:
		print("zombie hit")
		hitsound.play()


func _on_rledge_body_exited(body: Node2D) -> void:
	if body is ground and Input.is_action_pressed("right")  and not Input.is_action_pressed("left"):
		if Input.is_action_pressed("up"):
			print("rledge")
			velocity.y = 0
			animated_sprite.play("vault")
			vault = 1
			waiting = 1
			await get_tree().create_timer(.15).timeout
			velocity.y = -230
			velocity.x = 50
			await get_tree().create_timer(.15).timeout
			velocity.y = -10
			velocity.x = 450
			await get_tree().create_timer(.1).timeout
			velocity.y = 40
			velocity.x = 100
			await get_tree().create_timer(.1).timeout
			waiting = 0
			vault = 0
	
	
	
	
func _on_lledge_body_exited(body: Node2D) -> void:
	if body is ground and Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		if Input.is_action_pressed("up"):
			print("lledge")
			velocity.y = 0
			animated_sprite.play("vault")
			vault = 1
			waiting = 1
			await get_tree().create_timer(.15).timeout
			velocity.y = -230
			velocity.x = -50
			await get_tree().create_timer(.15).timeout
			velocity.y = -10
			velocity.x = -450
			await get_tree().create_timer(.1).timeout
			velocity.y = 40
			velocity.x = -100
			await get_tree().create_timer(.1).timeout
			waiting = 0
			vault = 0
	
	
	
