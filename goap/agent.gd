#
# This script integrates the actor (NPC) with goap.
# In your implementation you could have this logic
# inside your NPC script.
#
# As good practice, I suggest leaving it isolated like
# this, so it makes re-use easy and it doesn't get tied
# to unrelated implementation details (movement, collisions, etc)
extends Node

class_name GoapAgent

var _goals
var _current_goal
var _current_plan
var _current_plan_step = 0
var _action_planner

var _actor

#
# On every loop this script checks if the current goal is still
# the highest priority. if it's not, it requests the action planner a new plan
# for the new high priority goal.
#
func _process(delta):
	# Set actor context so WorldState.get_state/set_state are scoped to this character
	WorldState.current_actor_id = _actor.char_id

	var goal = _get_best_goal()
	var need_replan = (
		_current_goal == null
		or goal != _current_goal
		or _current_plan == null
		or _current_plan.size() == 0
	)

	if need_replan:
		var blackboard = {
			"position": _actor.position,
			"char_id": _actor.char_id,
		}
		var char_state = WorldState._char_states.get(_actor.char_id, {})
		for s in char_state:
			blackboard[s] = char_state[s]

		_current_goal = goal
		_current_plan = _action_planner.get_plan(_current_goal, blackboard)
		_current_plan_step = 0
	else:
		_follow_plan(_current_plan, delta)

	WorldState.current_actor_id = ""


func init(actor, goals: Array):
	_actor = actor
	_goals = goals
	# Each agent gets its own planner with its own action instances so that
	# per-action state (timers, positions) is never shared between characters.
	_action_planner = GoapActionPlanner.new()
	_action_planner.set_actions([
		BuildFirepitAction.new(),
		ChopTreeAction.new(),
		CollectFromWoodStockAction.new(),
		CalmDownAction.new(),
		FindCoverAction.new(),
		FindFoodAction.new(),
		MeditateAction.new(),
		WeakMeditateAction.new(),
		WanderAction.new(),
	])


#
# Returns the highest priority goal available.
#
func _get_best_goal():
	var highest_priority

	for goal in _goals:
		if goal.is_valid() and (highest_priority == null or goal.priority() > highest_priority.priority()):
			highest_priority = goal

	return highest_priority


#
# Executes plan. This function is called on every game loop.
# "plan" is the current list of actions, and delta is the time since last loop.
#
# Every action exposes a function called perform, which will return true when
# the job is complete, so the agent can jump to the next action in the list.
#
func _follow_plan(plan, delta):
	if plan.size() == 0:
		return

	var is_step_complete = plan[_current_plan_step].perform(_actor, delta)
	if is_step_complete:
		if _current_plan_step < plan.size() - 1:
			_current_plan_step += 1
		else:
			# Final step completed — clear plan so next frame triggers a replan
			_current_plan = []
