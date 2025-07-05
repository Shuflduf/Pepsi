extends Node3D
class_name VisionSystem

signal object_detected(object: Node3D, distance: float)
signal object_lost(object: Node3D)

@export var fov_angle: float = 60.0  # Field of view angle in degrees
@export var max_range: float = 20.0  # Maximum vision range
@export var ray_count: int = 16  # Number of rays to cast for detection
@export var update_frequency: float = 0.1  # How often to update vision (in seconds)
@export var show_debug_visualization: bool = true

var detected_objects: Array[Node3D] = []
var camera: Camera3D
var update_timer: float = 0.0
var space_state: PhysicsDirectSpaceState3D

func _ready():
	# Find the camera in the parent
	camera = get_parent().find_child("Camera3D", true, false)
	if not camera:
		push_error("VisionSystem: No Camera3D found in parent hierarchy")
		return
	
	# Get the physics space
	space_state = get_world_3d().direct_space_state

func _process(delta):
	if not camera or not space_state:
		return
	
	update_timer += delta
	if update_timer >= update_frequency:
		update_timer = 0.0
		update_vision()
	
	if show_debug_visualization:
		draw_debug_visualization()

func update_vision():
	var new_detected_objects: Array[Node3D] = []
	
	# Cast rays in a cone pattern to detect objects
	for i in range(ray_count):
		var ray_result = cast_vision_ray(i)
		if ray_result and ray_result.collider:
			var detected_object = ray_result.collider as Node3D
			if detected_object and not detected_object in new_detected_objects:
				new_detected_objects.append(detected_object)
	
	# Check for newly detected objects
	for obj in new_detected_objects:
		if not obj in detected_objects:
			var distance = global_position.distance_to(obj.global_position)
			object_detected.emit(obj, distance)
	
	# Check for lost objects
	for obj in detected_objects:
		if not obj in new_detected_objects:
			object_lost.emit(obj)
	
	detected_objects = new_detected_objects

func cast_vision_ray(ray_index: int) -> Dictionary:
	if not camera or not space_state:
		return {}
	
	# Calculate the direction for this ray
	var angle_step = fov_angle / max(ray_count - 1, 1)  # Prevent division by zero
	var current_angle = -fov_angle / 2.0 + (ray_index * angle_step)
	
	# Get camera's forward direction and create ray direction
	var camera_transform = camera.global_transform
	var forward = -camera_transform.basis.z
	var right = camera_transform.basis.x
	var up = camera_transform.basis.y
	
	# Create ray direction by rotating around Y axis (horizontal) and X axis (vertical)
	var ray_direction = forward.rotated(up, deg_to_rad(current_angle))
	
	# Cast the ray
	var ray_start = camera.global_position
	var ray_end = ray_start + ray_direction * max_range
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [get_parent()]  # Don't hit the player itself
	
	var result = space_state.intersect_ray(query)
	
	# If no collision, still return the end position for visualization
	if result.is_empty():
		result = {"position": ray_end, "normal": Vector3.ZERO, "collider": null}
	
	return result

func draw_debug_visualization():
	if not camera:
		return
	
	var camera_pos = camera.global_position
	var camera_transform = camera.global_transform
	var forward = -camera_transform.basis.z
	var up = camera_transform.basis.y
	
	# Draw field of view cone
	var left_angle = deg_to_rad(-fov_angle / 2.0)
	var right_angle = deg_to_rad(fov_angle / 2.0)
	
	var left_direction = forward.rotated(up, left_angle)
	var right_direction = forward.rotated(up, right_angle)
	
	var left_end = camera_pos + left_direction * max_range
	var right_end = camera_pos + right_direction * max_range
	var center_end = camera_pos + forward * max_range
	
	# Draw FOV cone outline
	DebugDraw3D.draw_line(camera_pos, left_end, Color.CYAN, 0.1)
	DebugDraw3D.draw_line(camera_pos, right_end, Color.CYAN, 0.1)
	DebugDraw3D.draw_line(camera_pos, center_end, Color.CYAN, 0.1)
	DebugDraw3D.draw_line(left_end, right_end, Color.CYAN, 0.1)
	
	# Draw rays
	for i in range(ray_count):
		var ray_result = cast_vision_ray(i)
		if ray_result and ray_result.has("position"):
			var hit_something = ray_result.collider != null
			var ray_color = Color.GREEN if hit_something else Color.RED
			var end_pos = ray_result.position
			DebugDraw3D.draw_line(camera_pos, end_pos, ray_color, 0.03)
			
			# Draw hit point
			if hit_something:
				DebugDraw3D.draw_sphere(end_pos, 0.1, Color.GREEN, 0.1)
	
	# Draw detected objects with enhanced visualization
	for obj in detected_objects:
		if obj and is_instance_valid(obj):
			var distance = camera_pos.distance_to(obj.global_position)
			var obj_pos = obj.global_position
			
			# Draw object highlight
			DebugDraw3D.draw_sphere(obj_pos, 0.3, Color.YELLOW, 0.1)
			
			# Draw line to object
			DebugDraw3D.draw_line(camera_pos, obj_pos, Color.YELLOW, 0.1)
			
			# Draw distance text above object
			DebugDraw3D.draw_text(obj_pos + Vector3(0, 1, 0), 
				"%s\n%.1fm" % [obj.name, distance], 14, Color.WHITE)
			
			# Draw object bounds if available
			if obj.has_method("get_aabb"):
				var aabb = obj.get_aabb()
				DebugDraw3D.draw_box(obj_pos, obj.transform.basis.get_rotation_quaternion(), 
					aabb.size, Color.YELLOW, false, 0.05)
	
	# Draw vision system info in 3D space
	var info_pos = camera_pos + forward * 2.0 + up * 1.5
	DebugDraw3D.draw_text(info_pos, 
		"Vision System\nFOV: %.0f°\nRange: %.1fm\nObjects: %d" % 
		[fov_angle, max_range, detected_objects.size()], 
		16, Color.CYAN)

func get_detected_objects() -> Array[Node3D]:
	return detected_objects

func is_object_visible(object: Node3D) -> bool:
	return object in detected_objects