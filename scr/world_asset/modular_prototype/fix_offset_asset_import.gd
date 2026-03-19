@tool
extends EditorScenePostImport

func _post_import(scene):
	_fix_node(scene)
	return scene

func _fix_node(node):
	if node is MeshInstance3D and node.mesh:
		var scale = node.scale
		
		if scale != Vector3.ONE:
			var old_mesh = node.mesh
			var new_mesh = ArrayMesh.new()

			for i in range(old_mesh.get_surface_count()):
				var arrays = old_mesh.surface_get_arrays(i)
				var verts = arrays[Mesh.ARRAY_VERTEX]

				for j in range(verts.size()):
					verts[j] *= scale  

				arrays[Mesh.ARRAY_VERTEX] = verts
				new_mesh.add_surface_from_arrays(
					Mesh.PRIMITIVE_TRIANGLES,
					arrays
				)

			node.mesh = new_mesh
			node.scale = Vector3.ONE

	if node is Node3D:
		node.transform.origin = Vector3.ZERO

	for child in node.get_children():
		_fix_node(child)
