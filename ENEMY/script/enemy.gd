extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 1.0 

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite: Sprite3D = $Sprite3D

var target_node: Node3D
var can_attack: bool = true

func _ready() -> void:
	target_node = get_tree().root.find_child("Player", true, false)
	
	# 2. Add to player's tracking list if player exists
	if target_node and "Total_enemies" in target_node:
		target_node.Total_enemies.append(self)

	# 3. Path update optimization
	var path_timer = Timer.new()
	path_timer.wait_time = 0.2
	path_timer.autostart = true
	add_child(path_timer)
	path_timer.timeout.connect(_update_path)

func _update_path() -> void:
	if target_node and target_node.get("Health") > 0:
		nav_agent.target_position = target_node.global_position

func _physics_process(delta: float) -> void:
	if not target_node or target_node.get("Health") <= 0:
		velocity = Vector3.ZERO
		return
	
	var dist_to_player = global_position.distance_to(target_node.global_position)
	
	if dist_to_player <= attack_range:
		if can_attack:
			_attack_player()
		velocity = Vector3.ZERO
		return 

	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		return

	var next_path_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	direction.y = 0 
	
	velocity = direction.normalized() * speed
	move_and_slide()

	if direction.length() > 0.1:
		var target_rot = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)

func _attack_player() -> void:
	can_attack = false
	if target_node.has_method("_damage"):
		target_node._damage()
		
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
