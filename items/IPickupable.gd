class_name IPickupable
# parent class because it brings physics with it.
extends RigidBody3D

# This name is default and used in all childs 
# so this script can be used as parent for all things to pickup
# is used to disable the items in hand not to collide with 
# the player it self (would let you fly)
@onready var collision_shape_3d = %CollisionShape3D

func _ready():
	# this mode make the items static and not run any more 
	# physics calulations
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func _physics_process(delta):
	# fell out of world remove it.
	if global_position.y < -20:
		self.queue_free()

# item is picked up freeze it
func pickup():
	collision_shape_3d.disabled = true
	freeze = true

# item is picked up unfreeze it
func release():
	collision_shape_3d.disabled = false
	freeze = false
	
