#
# This NPC uses GOAP as AI. This script handles
# Only NPC related stuff, like moving and animations.

# All AI related code is inside GoapAgent.
#
# This is optional, but I usually like to have my AI code
# separated from the "dumb" modules that handle the basic low
# level stuff, this allows me to use the same Agent in different
# nodes.
#
extends CharacterBody2D

var is_moving = false
var is_attacking = false
var _nav_target := Vector2.ZERO

func _ready():
  # Here is where I define which goals are available for this
  # npc. In this implementation, goals priority are calculated
  # dynamically. Depending on your use case you might want to
  # have a way to define different goal priorities depending on
  # npc.
	var agent = GoapAgent.new()
	agent.init(self, [
		KeepFirepitBurningGoal.new(),
		KeepFedGoal.new(),
		CalmDownGoal.new(),
		KeepSaneGoal.new(),
		RelaxGoal.new()
	])
	
	add_child(agent)


func _process(_delta):
	$labels/labels/afraid_label.visible = WorldState.get_state("is_frightened", false)
	$labels/labels/hungry_label.visible = WorldState.get_state("hunger", 0) >= 50

	if is_attacking:
		$body.play("attack")
	elif is_moving:
		is_moving = false
	else:
		$body.play("idle")



func navigate_to(target: Vector2):
	if _nav_target != target:
		_nav_target = target
		$NavigationAgent2D.target_position = target

func move_to(direction, delta):
	# direction is passed in by GOAP actions as direction_to(target).
	# We derive the actual target by projecting along that direction and
	# update the nav agent so the path avoids water obstacles.
	var intended_target = position + direction * 2000.0
	navigate_to(intended_target)

	is_moving = true
	is_attacking = false
	$body.play("run")

	var next_point = $NavigationAgent2D.get_next_path_position()
	var nav_direction = position.direction_to(next_point)

	if nav_direction.x > 0:
		turn_right()
	else:
		turn_left()

	move_and_collide(nav_direction * delta * 100)



func turn_right():
	if not $body.flip_h:
		return

	$body.flip_h = false


func turn_left():
	if $body.flip_h:
		return

	$body.flip_h = true


func chop_tree(tree):
	var is_finished = tree.chop()
	is_attacking = not is_finished
	return is_finished


func calm_down():
	if WorldState.get_state("is_frightened") == false:
		return true

	if $calm_down_timer.is_stopped():
		$calm_down_timer.start()

	return false


func _on_detection_radius_body_entered(body):
	if body.is_in_group("troll"):
		WorldState.set_state("is_frightened", true)
		var current_sanity = WorldState.get_state("sanity", 100)
		WorldState.set_state("sanity", max(0, current_sanity - 45))


func _on_calm_down_timer_timeout():
	WorldState.set_state("is_frightened", false)
