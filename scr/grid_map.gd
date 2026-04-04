extends GridMap


func _ready() -> void:
	# Bake all meshes into a single optimized mesh
	# false = do NOT generate lightmap UVs at runtime (this was crashing/freezing the engine)
	make_baked_meshes(false)

	var baked_meshes: Array = get_bake_meshes()
	print("Created ", baked_meshes.size() / 2, " baked mesh(es)")

	# Optional: Hide or disable the original GridMap
	# The baked meshes are stored internally - you can access them via get_bake_mesh_instance()

	# To actually USE the baked mesh in scene:
	for i in range(0, baked_meshes.size(), 2):
		var mesh: Mesh = baked_meshes[i] as Mesh
		var mesh_transform: Transform3D = baked_meshes[i + 1] as Transform3D
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.mesh = mesh
		# Keep it perfectly aligned with the GridMap's world position
		mesh_instance.global_transform = self.global_transform * mesh_transform
		# Add to the parent so it's a sibling, avoiding the invisibility cascade
		get_parent().call_deferred("add_child", mesh_instance)

	# Hide the original GridMap to stop it from rendering individual blocks (saving draw calls)
	# BUT leave it in the scene tree so its collision shapes still work!
	self.visible = false
