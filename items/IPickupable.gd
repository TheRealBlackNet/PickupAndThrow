class_name IPickupable
extends RigidBody3D

# This name is default and used in all childs 
# so this script can be used as parent for all things to pickup
@onready var collision_shape_3d = %CollisionShape3D

func _ready():
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func _physics_process(delta):
	# fell out of world
	if global_position.y < -20:
		self.queue_free()

func pickup():
	collision_shape_3d.disabled = true
	freeze = true

func release():
	collision_shape_3d.disabled = false
	freeze = false
	
