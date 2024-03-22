class_name Player
extends CharacterBody3D

@onready var camera:Camera3D = %Camera
@onready var raycast:RayCast3D = %RayCast
@onready var head = %Head
@onready var throwdirection = %Throwdirection

@onready var box_holder = %BoxHolder
@onready var throw_point = %ThrowPoint

@onready var ballFactory = preload("res://items/Ball.tscn")

@export_category("WorldNodes")
@export var pickupAbleDropNode:Node3D
@export var throwAbleDropNode:Node3D

var movement_speed = 5
var jump_strength = 8
var mouse_sensitivity:float = 700

var movement_velocity:Vector3
var input_mouse: Vector2
var rotation_target: Vector3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var handIsEmpty = true
var itemInHand:IPickupable
var throwForce : float = 50



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Mouse movement
func _input(event):
	if event is InputEventMouseMotion:
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func _physics_process(delta):
	movement_handler(delta)
	action_handler()
	
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func movement_handler(delta):
	# FALL
	gravity += 20 * delta
	if gravity > 0 and is_on_floor():
		gravity = 0
	
	# JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		gravity = -jump_strength
	
	# ROTATION
	# LIMIT CAMERA MOVEMENT	
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	# ROTATE CAMERA
	head.rotation.z = lerp_angle(head.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	head.rotation.x = lerp_angle(head.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	# Movement
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	var applied_velocity: Vector3
	movement_velocity = transform.basis * movement_velocity # Move forward
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	velocity = applied_velocity
	move_and_slide()


func action_handler():
	#
	# Spwaning a new ball and throw it:
	#
	if Input.is_action_just_pressed("throw"):
		# new ball
		var newBall:Ball = ballFactory.instantiate()
		# place the ball into hands pos
		newBall.global_position = throw_point.global_position
		throwAbleDropNode.add_child(newBall)
		# throw it into view direction
		(newBall as RigidBody3D).apply_central_impulse(\
			(throwdirection.global_position - head.global_position)\
			 *  throwForce)
		
		# remove after 20 balls in the map the first one
		if throwAbleDropNode.get_child_count(false) > 20:
			(throwAbleDropNode.get_children(false)[0] as Ball).queue_free()
	
	#
	# pickup and throw
	#
	if Input.is_action_just_pressed("pickup") \
		or Input.is_action_just_pressed("placedown"):
		if !handIsEmpty and itemInHand != null:
			releaseItem(itemInHand, !Input.is_action_just_pressed("placedown"))
		else:
			raycast.force_raycast_update()
			if raycast.is_colliding(): 
				var collider:Object = raycast.get_collider()
				var collision_point:Vector3 = raycast.get_collision_point()
				var origin:Vector3 = raycast.global_transform.origin
				var distance:float = origin.distance_to(collision_point)
				
				if collider is IPickupable:
					pickupItem(collider)


func pickupItem(item:IPickupable):
	if handIsEmpty:
		handIsEmpty = false
		itemInHand = item
		itemInHand.pickup()
		item.reparent(box_holder,false)
		item.position = Vector3(0,0,0)

func releaseItem(item:IPickupable, throwIt:bool):
	if !handIsEmpty:
		item.reparent(pickupAbleDropNode,true)
		itemInHand.release()
		if throwIt:
			itemInHand.apply_central_impulse(\
				(throwdirection.global_position - head.global_position)\
				 * throwForce)
		handIsEmpty = true
		itemInHand = null
		
