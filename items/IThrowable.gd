class_name IThrowable
extends RigidBody3D

func _physics_process(delta):
	# fell out of world
	if global_position.y < -20:
		self.queue_free()
