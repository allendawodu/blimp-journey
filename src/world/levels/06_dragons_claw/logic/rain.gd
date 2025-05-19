extends GPUParticles2D

@export var camera: Node
@export var smoothing: float = 0.1


func _process(delta: float) -> void:
	if not camera:
		return
	
	# Smoothly interpolate the position of the particles to the camera position
	global_position.x = lerpf(global_position.x, camera.global_position.x, smoothing)
	process_material.set_param(ParticleProcessMaterial.PARAM_ANGLE, Vector2.ONE * remap(global_position.x - camera.global_position.x, -150, 150, -20, 20))
