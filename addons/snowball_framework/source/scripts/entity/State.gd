class_name StateMain
extends Node

var entity: Entity = null

var climbing_normal: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var input: Vector3 = Vector3.ZERO
var facing_dir: float = 0

func set_gravity(state: PhysicsDirectBodyState, gravity: int = 50) -> void:
	var can_climb: bool = false
	if is_instance_valid(entity.climbing_rays):
		var norm_avg = Vector3.ZERO
		var rays_colliding := 0
		for ray in entity.climbing_rays.get_children():
			var r : RayCast = ray
			if r.is_colliding():
				if r.get_collider().is_in_group("climbable"):
					can_climb = true
					rays_colliding += 1
					norm_avg += r.get_collision_normal()
		if !norm_avg or !can_climb:
			climbing_normal = Vector3.UP
		else:
			climbing_normal = norm_avg / rays_colliding
	else:
		climbing_normal = Vector3.UP
	entity.global_transform = Utility.apply_surface_align(entity.global_transform, climbing_normal)
	state.add_central_force(lerp(15, gravity, 0.1) * -climbing_normal)

func set_hang_align(state: PhysicsDirectBodyState, gravity: int = 50) -> void:
	if is_instance_valid(entity.climbing_rays):
		var norm_avg = Vector3.ZERO
		var rays_colliding := 0
		for ray in entity.climbing_rays.get_children():
			var r : RayCast = ray
			if r.is_colliding():
				rays_colliding += 1
				norm_avg += r.get_collision_normal()
		if !norm_avg:
			climbing_normal = Vector3.UP
		else:
			climbing_normal = norm_avg / rays_colliding
	else:
		climbing_normal = Vector3.UP
	entity.global_transform = Utility.apply_surface_align(entity.global_transform, climbing_normal)

func get_joy_input() -> Vector3:
	input.x = Input.get_action_strength(Device.stick_main_left) - Input.get_action_strength(Device.stick_main_right)
	input.z = Input.get_action_strength(Device.stick_main_up) - Input.get_action_strength(Device.stick_main_down)
	var input_length = input.length()
	if input_length > 1:
		input /= input_length
	return input

func apply_movement(state: PhysicsDirectBodyState, multiplier: float, roll: bool = false) -> void:
	if entity.is_controlled() and !entity.attached_to_location and !entity.interacting:
		direction = -get_joy_input().rotated(Vector3.UP, SB.camera.rotation.y)
		direction = direction.rotated(Vector3.LEFT, -entity.rotation.x).rotated(Vector3.RIGHT, -entity.rotation.y)
		if direction != Vector3.ZERO:
			if roll:
				state.add_force((entity.speed * multiplier) * direction, -direction)
			else:
				state.add_central_force((entity.speed * multiplier) * direction)
				#entity.anim_tween.interpolate_property(entity.skeleton, "rotation:y", entity.skeleton.rotation.y, atan2(-direction.x, -direction.z), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				#entity.anim_tween.start()
#		else:
#			state.linear_velocity = Vector3.ZERO

func apply_shimmy(state: PhysicsDirectBodyState, multiplier: float) -> void:
	direction = Vector3(-get_joy_input().x, 0, 0).rotated(Vector3.UP, entity.skeleton. rotation.y)
	if direction != Vector3.ZERO:
		state.add_central_force((entity.speed * multiplier) * direction)

func apply_rotation():
	if SB.camera.looking:
		var cam_facing: Vector3 = SB.camera.rotation_degrees
		facing_dir = atan2(cam_facing.x, cam_facing.z)
	elif direction != Vector3.ZERO:
		facing_dir = atan2(-direction.x, -direction.z)
		entity.skeleton.rotation.y = lerp_angle(entity.skeleton.rotation.y, facing_dir, 0.2)
		entity.collision.rotation.y = lerp_angle(entity.collision.rotation.y, facing_dir, 0.2)

func is_on_floor() -> bool:
	if is_instance_valid(entity.climbing_rays):
		for ray in entity.climbing_rays.get_children():
			var r : RayCast = ray
			if r.is_colliding():
				return true
	elif is_instance_valid(entity.floor_checker):
		if entity.floor_checker.is_colliding():
			return true
	return false
