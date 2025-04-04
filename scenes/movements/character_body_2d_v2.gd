extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim_sprite := $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED

		# Cambiar animación a "run" si no está ya
		if anim_sprite.animation != "run":
			anim_sprite.play("run")

		# Orientar sprite según la dirección
		anim_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		# Cambiar animación a "idle" si no hay dirección
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")

	move_and_slide()

	# Detectar y empujar RigidBodies
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var body := collision.get_collider() as RigidBody2D
			# Aplica una fuerza o impulso
			print(velocity)
			body.apply_impulse(velocity * 1)
