class_name IThrowable
# parent class because it brings physics with it.
extends RigidBody3D

func _physics_process(delta):
	# fell out of world remove it
	if global_position.y < -20:
		self.queue_free()
