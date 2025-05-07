extends Node2D

@export var player: CharacterBody2D

@export var Camera_Zone0: PhantomCamera2D
@export var Camera_Zone1: PhantomCamera2D
@export var Camera_Zone2: PhantomCamera2D
@export var Camera_Zone3: PhantomCamera2D
@export var Camera_Zone4: PhantomCamera2D

@export var Interaction_Area_1: Area2D
@export var Interaction_Camera_1: PhantomCamera2D

var current_camera_zone: int = 0 # starting off at zero

var is_active_interaction: bool = false
var active_interaction: Area2D

func _input(event):
	if Input.is_action_just_pressed("e"): #interaction with the enemy/npc' in general with the Key E
		if is_active_interaction: #if there is an active interaction
			is_active_interaction = false
			update_camera() 
		else:
			find_interaction()

func find_interaction(): # we check/search every area for an interaction until we find one
	var areas: Array = [Interaction_Area_1] # to check every area => using an Array for that
	var found_interaction_area: Area2D
	
	for area in areas: #checking all areas in that array
		if found_interaction_area == null: # havent found interaction area
			var overlapping_bodies = area.get_overlapping_bodies()
			for i in overlapping_bodies:
				if i == player:
					print("In Zone") # to counter-check if there is an interaction available
					found_interaction_area = area
					is_active_interaction = true
					active_interaction = found_interaction_area
					update_camera()
				else:
					print("Not In Zone") # by pressing the key E you see the prints
	

func update_current_zone(body, zone_a, zone_b):
	if body == player:
		match current_camera_zone:
			zone_a:
				current_camera_zone = zone_b
			zone_b:
				current_camera_zone = zone_a
		update_camera()
# if the body that enters in the collision shape is the player => we switch zones
# reason why zone_a and zone_b are like this: if we cross zone A to B, where current zone was 0
# => we updated; moving from 0 to 1 collision, so we pass through 0 to 1; we decide which one we are in
# if zone A matches the current (camera) zone, we switch to zone B
# when current camera zone is at 0 we also match zone A which is also 0. Then we end up switching to B
# now we are at 1 (zone B) aka current camera zone is at 1. If we go back we switch from zone B with 1 to zone A with 0. So current camera zone goes from 1 back to 0. Like a toggle.

func update_camera():
	# print("Camera Zone: ", current_camera_zone)
	var cameras = [Camera_Zone0, Camera_Zone1, Camera_Zone2, Camera_Zone3,Camera_Zone4]
	for camera in cameras:
		if camera != null:
			camera.priority = 0
	
	if is_active_interaction: #if we find interaction the camera focuses on the interactive area which we triggered
		match active_interaction: #matching interaction with whatever it might be
			Interaction_Area_1:
				Interaction_Camera_1.priority = 1
	else: #when we arent in an interactive area, camera switches back to "normal" state/previous state => goind back to zones
		match current_camera_zone:
			0:
				Camera_Zone0.priority = 1
			1:
				Camera_Zone1.priority = 1
			2:
				Camera_Zone2.priority = 1
			3:
				Camera_Zone3.priority = 1
			4:
				Camera_Zone4.priority = 1
# by using the priority the priority resets by entering the each individual zones, because assigning it in the priority setting in inspector would be a chaos/complicated
# with that setting we transition from each phantom camera setting

# side nodes: player is not following with the camera; camera is almost on a path, going down with the player, e.g. zone 3-4 (cool effect)
# to avoid jitters: project settings and changing in application the max fps amount

func screen_shake_effect(shake_power, duration, camera):
	await get_tree().create_timer(1.0).timeout
	
	var og_global_pos: Vector2 = camera.global_position #fixing camera position after e.g. cliff fall, position of the camera that is changing to
	
	for i in duration: # to make actual shake effect: to call as many times as the duration calls for => using for loop
		var shake_effect = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_power #random range (Xs,Ys); random float (Xs, Ys); Shake Power
		camera.global_position += shake_effect # changing camera's global position based on shake effect | that line as solo call only shakes one time instead of earthquake like behaviour
		await get_tree().create_timer(0.01).timeout #await is for a little break inbetween, similar to pause in java; avoiding things happening at the same time in one frame
	
	camera.global_position = og_global_pos #when screen shake is over

# current zone area divider
func _on_zone_01_body_entered(body: Node2D) -> void:
	update_current_zone(body, 0, 1)
# calling and passing that through (collision shape that divides the zones)

func _on_zone_12_body_entered(body: Node2D) -> void:
	update_current_zone(body, 1, 2)
	# the order of the numbers isn't important in () because it toggles it so or so. Only important to call the correct and needed zones

func _on_zone_23_body_entered(body: Node2D) -> void:
	update_current_zone(body, 2, 3)
	# await get_tree().create_timer(1.0).timeout # jump off the cliff timer
	screen_shake_effect(5, 10, Camera_Zone3) # (power, duration, camera)
	# shake effect should occure when we fall on the ground not midair or before.

func _on_zone_34_body_entered(body: Node2D) -> void:
	update_current_zone(body, 3, 4)

#(follow) damping in zone 4 phantom camera settings under follow parameters causes the camera to lag behind the player (stylistic choice)
