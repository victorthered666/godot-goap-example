# This NPC does not use GOAP.
# This is just a simple script which chooses
# a random position in the scene to move to.
extends CharacterBody2D

var _target


func _ready():
	_pick_random_position()
	$body.play("run")


func _process(delta):
	if $NavigationAgent2D.is_navigation_finished():
		$body.play("idle")
		$rest_timer.start()
		set_process(false)
		return

	var next_point = $NavigationAgent2D.get_next_path_position()
	var direction = position.direction_to(next_point)

	if direction.x > 0:
		turn_right()
	else:
		turn_left()

	# warning-ignore:return_value_discarded
	move_and_collide(direction * delta * 100)


func _pick_random_position():
	randomize()
	_target = Vector2(randi() % 10680 + 120, randi() % 5880 + 120)
	$NavigationAgent2D.target_position = _target


func _on_rest_timer_timeout():
	_pick_random_position()
	$body.play("run")
	set_process(true)


func turn_right():
	if not $body.flip_h:
		return

	$body.flip_h = false
	$RayCast2D.target_position *= -1


func turn_left():
	if $body.flip_h:
		return

	$body.flip_h = true
	$RayCast2D.target_position *= -1
