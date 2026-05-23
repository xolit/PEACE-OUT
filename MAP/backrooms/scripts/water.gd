extends MeshInstance3D

# Drag and drop your water material here in the Inspector
@export var water_material: Material

# Speed at which the water flows
@export var flow_speed: Vector2 = Vector2(0.05, -0.08)

# Scale variation for dynamic ripples
@export var ripple_speed: float = 0.5
@export var ripple_strength: float = 0.05

func _process(delta: float) -> void:
	if water_material:
		# Scroll the UV1 Offset
		water_material.uv1_offset.x += flow_speed.x * delta
		water_material.uv1_offset.y += flow_speed.y * delta
		
		# Calculate dynamic wave scale over time
		var time = Time.get_ticks_msec() * 0.001 * ripple_speed
		
		# Gently shift the scale to simulate moving waves
		water_material.uv1_scale.x = 1.0 + sin(time) * ripple_strength
		water_material.uv1_scale.y = 1.0 + cos(time) * ripple_strength
