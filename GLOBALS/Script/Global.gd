extends Node

# Preload your loading screen scene
@onready var loading_screen_scene: PackedScene = preload("res://LOADING/scene/loading.tscn")

# Keep references
var loading_screen: Node = null
var is_loading: bool = false

# Call this from anywhere:  Global.change_scene("res://Main.tscn")
func change_scene(target_path: String) -> void:
	if is_loading:
		return  # prevent double calls

	is_loading = true

	# Create loading screen
	loading_screen = loading_screen_scene.instantiate()
	get_tree().root.add_child.call_deferred(loading_screen)

	# Wait briefly so the loading screen is visible
	await get_tree().create_timer(0.8).timeout

	await load_scene_async(target_path)


# Handles async scene loading (Godot 4 way)
func load_scene_async(scene_path: String) -> void:
	var progress_bar: ProgressBar = loading_screen.get_node_or_null("ProgressBar")

	# Start threaded loading
	var result = ResourceLoader.load_threaded_request(scene_path)
	if result != OK:
		push_error("Failed to start loading: " + scene_path)
		is_loading = false
		return

	var status = ResourceLoader.THREAD_LOAD_IN_PROGRESS
	var progress := []

	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		if progress_bar:
			progress_bar.value = int(progress[0] * 100)
		await get_tree().process_frame

	# Wait a little so player sees 100%
	await get_tree().create_timer(1.5).timeout

	# Load result
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var resource = ResourceLoader.load_threaded_get(scene_path)
		if resource:
			var new_scene = resource.instantiate()

			# 🔹 Remove previous scene before adding new one
			var current_scene = get_tree().current_scene
			if current_scene:
				current_scene.queue_free()

			get_tree().root.add_child(new_scene)
			get_tree().current_scene = new_scene
		else:
			push_error("Failed to instantiate: " + scene_path)
	else:
		push_error("Scene failed to load, status: " + str(status))

	# Remove loading screen
	if loading_screen:
		loading_screen.queue_free()
		loading_screen = null

	is_loading = false
