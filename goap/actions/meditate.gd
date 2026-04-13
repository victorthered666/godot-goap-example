extends GoapAction

class_name MeditateAction

var _meditation_time = 0
var _meditation_duration = 5

func get_clazz(): return "MeditateAction"


func is_valid() -> bool:
	# 需要有火堆存在且角色不害怕
	return WorldState.get_elements("firepit").size() > 0 and not WorldState.get_state("is_frightened", false)


func get_cost(blackboard) -> int:
	if blackboard.has("position"):
		var closest = WorldState.get_closest_element("firepit", blackboard)
		if closest:
			return max(1, int(closest.position.distance_to(blackboard.position) / 50))
	return 2


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"sanity": 100
	}


func perform(actor, delta) -> bool:
	# 检查是否已经开始冥想
	if WorldState.get_state("is_meditating", false):
		# 已经开始冥想，即使火堆消失也要继续
		_meditation_time += delta
		
		# 冥想5秒后完成
		if _meditation_time >= _meditation_duration:
			WorldState.set_state("sanity", 100)
			WorldState.set_state("is_meditating", false)
			_meditation_time = 0
			return true
		
		return false
	
	# 还未开始冥想，需要找到火堆
	var closest_firepit = WorldState.get_closest_element("firepit", actor)
	if closest_firepit:
		if actor.position.distance_to(closest_firepit.position) > 1:
			actor.move_to(actor.position.direction_to(closest_firepit.position), delta)
			return false
		else:
			# 到达火堆附近，开始冥想
			WorldState.set_state("is_meditating", true)
			_meditation_time = 0
			return false
	else:
		# 没有火堆，无法开始冥想
		return false
