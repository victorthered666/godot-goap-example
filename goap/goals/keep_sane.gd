extends GoapGoal

class_name KeepSaneGoal

func get_clazz(): return "KeepSaneGoal"

# 当理智值低于50时，此目标有效
func is_valid() -> bool:
	return WorldState.get_state("sanity", 100) < 30


func priority() -> int:
	# 理智值越低，优先级越高，但始终低于CalmDown（10）
	var sanity = WorldState.get_state("sanity", 100)
	if sanity < 15:
		return 9
	elif sanity < 30:
		return 7
	return 5


func get_desired_state() -> Dictionary:
	return {
		"sanity": 100
	}
