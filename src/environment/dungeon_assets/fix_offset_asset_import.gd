@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Node:
	_fix_node(scene)
	return scene


func _fix_node(node: Node) -> void:
	if node is MeshInstance3D and node.mesh:
		var mesh_instance: MeshInstance3D = node
		var old_mesh: Mesh = mesh_instance.mesh
		var new_mesh: ArrayMesh = ArrayMesh.new()
		var local_transform: Transform3D = mesh_instance.transform
		var basis: Basis = local_transform.basis
		var normal_basis: Basis = basis.inverse().transposed()
		var aabb_min: Vector3 = Vector3.INF
		var aabb_max: Vector3 = -Vector3.INF

		# Bake rotation/scale and recenter to the local AABB center for GridMap alignment.
		for i: int in range(old_mesh.get_surface_count()):
			var arrays: Array = old_mesh.surface_get_arrays(i)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for j: int in range(verts.size()):
				var transformed: Vector3 = basis * verts[j]
				aabb_min = aabb_min.min(transformed)
				aabb_max = aabb_max.max(transformed)

		var recenter_offset: Vector3 = (aabb_min + aabb_max) * 0.5
		for i: int in range(old_mesh.get_surface_count()):
			var arrays: Array = old_mesh.surface_get_arrays(i)
			var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]

			for j: int in range(verts.size()):
				verts[j] = (basis * verts[j]) - recenter_offset

			arrays[Mesh.ARRAY_VERTEX] = verts

			var normals_array: Variant = arrays[Mesh.ARRAY_NORMAL]
			if normals_array is PackedVector3Array:
				var normals: PackedVector3Array = normals_array
				if normals.size() > 0:
					for j: int in range(normals.size()):
						normals[j] = (normal_basis * normals[j]).normalized()
					arrays[Mesh.ARRAY_NORMAL] = normals

			var tangents_array: Variant = arrays[Mesh.ARRAY_TANGENT]
			if tangents_array is PackedFloat32Array:
				var tangents: PackedFloat32Array = tangents_array
				if tangents.size() > 0:
					var tangent_count: int = tangents.size() / 4
					for j: int in range(tangent_count):
						var index: int = j * 4
						var tangent: Vector3 = Vector3(tangents[index], tangents[index + 1], tangents[index + 2])
						tangent = (normal_basis * tangent).normalized()
						tangents[index] = tangent.x
						tangents[index + 1] = tangent.y
						tangents[index + 2] = tangent.z
					arrays[Mesh.ARRAY_TANGENT] = tangents

			var primitive: int = old_mesh.surface_get_primitive_type(i)
			new_mesh.add_surface_from_arrays(primitive, arrays)
			new_mesh.surface_set_material(i, old_mesh.surface_get_material(i))

		mesh_instance.mesh = new_mesh
		mesh_instance.transform = Transform3D.IDENTITY

	for child: Node in node.get_children():
		_fix_node(child)
