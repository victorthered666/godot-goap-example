extends GoapAction

class_name WeakMeditateAction

var _meditation_time = 0
var _meditation_duration = 20

func get_clazz(): return "WeakMeditateAction"

func is_valid() -> bool:
	# Fallback meditation: valid when there is no firepit to meditate at properly
	return WorldState.get_elements("firepit").size() == 0

func get_cost(blackboard) -> int:
	if blackboard.has("position"):
		var closest = WorldState.get_closest_element("cover", blackboard)
		if closest:
			return max(1, int(closest.position.distance_to(blackboard.position) / 50)) + 5
	return 10

func get_preconditions() -> Dictionary:
	return {
		"protected": true
	}

func get_effects() -> Dictionary:
	return {
		"sanity": 100
	}

func perform(actor, delta) -> bool:
	if not WorldState.get_state("protected", false):
		var closest_cover = WorldState.get_closest_element("cover", actor)
		if closest_cover:
			if actor.position.distance_to(closest_cover.position) > 1:
				actor.move_to(actor.position.direction_to(closest_cover.position), delta)
				return false
		else:
			return false
	
	if _meditation_time == 0:
		WorldState.set_state("is_meditating", true)
	
	_meditation_time += delta
	
	if _meditation_time >= _meditation_duration:
		WorldState.set_state("sanity", 100)
		WorldState.set_state("is_meditating", false)
		_meditation_time = 0
		return true
	
	return false
