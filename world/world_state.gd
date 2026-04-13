extends Node

# Global shared state (scene elements, firepit presence, etc.)
var _state = {}

# Per-character state keyed by char_id
var _char_states = {}

# The currently active character id — set by GoapAgent before running goals/actions
var current_actor_id: String = ""


func get_state(state_name, default = null):
	if current_actor_id != "":
		var cs = _char_states.get(current_actor_id, {})
		if cs.has(state_name):
			return cs[state_name]
	return _state.get(state_name, default)


func set_state(state_name, value):
	if current_actor_id != "":
		if not _char_states.has(current_actor_id):
			_char_states[current_actor_id] = {}
		_char_states[current_actor_id][state_name] = value
	else:
		_state[state_name] = value


# Direct per-character access (used by satyr.gd and main.gd)
func get_char_state(char_id: String, state_name, default = null):
	var cs = _char_states.get(char_id, {})
	return cs.get(state_name, default)


func set_char_state(char_id: String, state_name, value):
	if not _char_states.has(char_id):
		_char_states[char_id] = {}
	_char_states[char_id][state_name] = value


func clear_state():
	_state = {}
	_char_states = {}


func get_elements(group_name):
	return self.get_tree().get_nodes_in_group(group_name)


func get_closest_element(group_name, reference):
	var elements = get_elements(group_name)
	var closest_element
	var closest_distance = 10000000

	for element in elements:
		var distance = reference.position.distance_to(element.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_element = element

	return closest_element


func console_message(object):
	var console = get_tree().get_nodes_in_group("console")[0] as TextEdit
	console.text += "\n%s" % str(object)
	console.set_caret_line(console.get_line_count())
