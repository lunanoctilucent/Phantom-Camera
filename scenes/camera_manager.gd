extends Node2D

@export var player: CharacterBody2D

@export var Camera_Zone0: PhantomCamera2D
@export var Camera_Zone1: PhantomCamera2D
@export var Camera_Zone2: PhantomCamera2D
@export var Camera_Zone3: PhantomCamera2D
@export var Camera_Zone4: PhantomCamera2D

var current_camera_zone: int = 0 
# starting off at zero

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

func _on_zone_01_body_entered(body: Node2D) -> void:
	update_current_zone(body, 0, 1)
# calling and passing that through (collision shape that divides the zones)

func _on_zone_12_body_entered(body: Node2D) -> void:
	update_current_zone(body, 1, 2)
	# the order of the numbers isn't important in () because it toggles it so or so. Only important to call the correct and needed zones

func _on_zone_23_body_entered(body: Node2D) -> void:
	update_current_zone(body, 2, 3)

func _on_zone_34_body_entered(body: Node2D) -> void:
	update_current_zone(body, 3, 4)

#(follow) damping in zone 4 phantom camera settings under follow parameters causes the camera to lag behind the player (stylistic stuff)
