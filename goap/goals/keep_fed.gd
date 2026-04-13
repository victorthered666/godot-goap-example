extends GoapGoal

class_name KeepFedGoal

func get_clazz(): return "KeepFedGoal"

# This is not a valid goal when hunger is less than 50.
func is_valid() -> bool:
	return WorldState.get_state("hunger", 0)  > 50 and WorldState.get_elements("food").size() > 0


func priority() -> int:
	var hunger = WorldState.get_state("hunger", 0)
	if hunger >= 90:
		return 12  # Critical starvation — beats CalmDown (10) and KeepSane (9)
	elif hunger >= 75:
		return 8   # Urgent — beats KeepSane low threshold (9 only when sanity < 30)
	return 1


func get_desired_state() -> Dictionary:
	return {
		"is_hungry": false
	}
