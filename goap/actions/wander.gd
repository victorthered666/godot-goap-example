extends GoapAction

class_name WanderAction

var _target_position = Vector2()
var _min_distance = 50
var _max_distance = 100
var _rest_time = 0
var _max_rest_time = 2  # 休息时间（秒）
var _is_resting = false

func _ready():
	# 只初始化一次随机数生成器
	randomize()

func get_clazz(): return "WanderAction"


func is_valid() -> bool:
	return true


func get_cost(_blackboard) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {
		"is_relaxed": true
	}


func perform(actor, delta) -> bool:
	# 检查是否已经开始漫游
	if not WorldState.get_state("is_relaxing", false):
		# 生成随机目标位置
		_pick_random_position(actor)
		# 设置放松状态
		WorldState.set_state("is_relaxing", true)
		_is_resting = false
		_rest_time = 0
	
	# 检查是否在休息
	if _is_resting:
		_rest_time += delta
		if _rest_time >= _max_rest_time:
			# 休息结束，生成新的目标位置
			_pick_random_position(actor)
			_is_resting = false
			_rest_time = 0
	else:
		# 移动到目标位置
		var direction = actor.position.direction_to(_target_position)
		var distance = actor.position.distance_to(_target_position)
		
		if distance > 5:
			# 放慢移动速度
			actor.move_to(direction, delta * 0.5)
		else:
			# 到达目标位置，开始休息
			_is_resting = true
			_rest_time = 0
	
	# 永远不自动结束，除非被其他目标打断
	return false


func _pick_random_position(actor):
	# 参考troll的移动代码，限制在地图范围内
	var map_width = 10680
	var map_height = 5880
	var margin = 120
	
	# 生成随机目标位置
	_target_position = Vector2(randi() % map_width + margin, randi() % map_height + margin)

