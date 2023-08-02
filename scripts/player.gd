extends CharacterBody3D

@onready var animation_tree = $visuals/player/AnimationTree
@onready var camera_mount = $camera_mount
@onready var visuals = $visuals

var speed = 5
const JUMP_VELOCITY = 4.5
const HIT_STAGGER = 20

var is_attack = false
var is_hit = false
var despawn_timer = 0

var hp = 10

# singal
signal player_hit
signal losed

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
#func _input(event):
#	if event is InputEventMouseMotion:
#		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
#		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
#		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func lose(delta):
	if despawn_timer > 0:
		despawn_timer -= delta
		if despawn_timer <= 0:
			emit_signal("losed")
#			queue_free()

func _physics_process(delta):
	lose(delta)
	
	if hp <= 0:
		animation_tree.set("parameters/die/transition_request", "true")
		return
		
	if animation_tree.get("parameters/attack/current_state") == "true":
		is_attack = true
	else:
		is_attack = false
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !is_attack:
		visuals.look_at(position + direction)
			
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _on_sword_hit_area_entered(area):
	if area.is_in_group("enemy") and area.get_parent().has_method('take_damage'):
		var dir = global_position.direction_to(area.get_parent().global_position)
		var damage_amount = 50
		area.get_parent().take_damage(damage_amount, dir)

func take_damage(dir):
	if !is_hit:
		hp -= 10
		
		if hp <= 0:
			despawn_timer = 2.0
			$attack_ctrl.await_time = 0
			
		emit_signal("player_hit")
#		velocity += dir * HIT_STAGGER
		is_hit = true
		await get_tree().create_timer(1).timeout
		is_hit = false
#	animation_tree.set("parameters/hurt_tr/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func restart():
	hp = 100
	despawn_timer = 0
	animation_tree.set("parameters/die/transition_request", "false")
	$attack_ctrl.await_time = 0
	
