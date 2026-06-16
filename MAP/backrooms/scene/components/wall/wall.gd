extends Node

@onready var csg_mesh_3d: CSGMesh3D = $CSGMesh3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not GlobalSave.Contents_to_save["walltexture"]:
		csg_mesh_3d.material.albedo_texture = null
