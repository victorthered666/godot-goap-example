extends GoapAction

class_name FindFoodAction


func get_clazz(): return "FindFoodAction"


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"is_hungry": false
	}


func perform(actor, delta) -> bool:
	var closest_food = WorldState.get_closest_element("food", actor)

	if closest_food == null:
		return false

	if closest_food.position.distance_to(actor.position) < 5:
		var new_hunger = max(0, WorldState.get_state("hunger", 0) - closest_food.nutrition)
		WorldState.set_state("hunger", new_hunger)
		closest_food.queue_free()
		return true

	actor.move_to(actor.position.direction_to(closest_food.position), delta)
	return false
