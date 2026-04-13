extends Node2D

const CHAR_IDS = ["satyr", "satyr2", "satyr3", "satyr4"]

var _selected_char_id: String = "satyr"
var _camera: Camera2D

@onready var _hunger_field = $HUD/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/hunger
@onready var _sanity_field = $HUD/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/sanity
@onready var _selector_buttons = {
	"satyr":  $HUD/VBoxContainer/MarginContainer/VBoxContainer/CharacterSelector/btn_satyr,
	"satyr2": $HUD/VBoxContainer/MarginContainer/VBoxContainer/CharacterSelector/btn_satyr2,
	"satyr3": $HUD/VBoxContainer/MarginContainer/VBoxContainer/CharacterSelector/btn_satyr3,
	"satyr4": $HUD/VBoxContainer/MarginContainer/VBoxContainer/CharacterSelector/btn_satyr4,
}


func _ready():
	_camera = $Camera2D
	_bind_camera_to("satyr")


func _bind_camera_to(char_id: String):
	var target = get_node_or_null(char_id)
	if target == null:
		return
	# Reparent camera to the chosen character so it follows them
	if _camera.get_parent():
		_camera.get_parent().remove_child(_camera)
	target.add_child(_camera)
	_camera.position = Vector2.ZERO


func _on_hanger_timer_timeout():
	# Tick hunger for every character independently
	for char_id in CHAR_IDS:
		var hunger = WorldState.get_char_state(char_id, "hunger", 0)
		if hunger < 100:
			hunger += 1
		WorldState.set_char_state(char_id, "hunger", hunger)

	# Update HUD bars for the currently selected character
	_hunger_field.value = WorldState.get_char_state(_selected_char_id, "hunger", 0)
	_sanity_field.value = WorldState.get_char_state(_selected_char_id, "sanity", 100)


func _on_select_character(char_id: String):
	_selected_char_id = char_id

	# Update button pressed states — only the chosen one stays pressed
	for id in _selector_buttons:
		_selector_buttons[id].button_pressed = (id == char_id)

	# Move camera to the newly selected character
	_bind_camera_to(char_id)

	# Immediately refresh HUD
	_hunger_field.value = WorldState.get_char_state(_selected_char_id, "hunger", 0)
	_sanity_field.value = WorldState.get_char_state(_selected_char_id, "sanity", 100)


func _on_reload_pressed():
	WorldState.clear_state()
	# warning-ignore:return_value_discarded
	self.get_tree().reload_current_scene()


func _on_pause_pressed():
	get_tree().paused = not get_tree().paused
	$HUD/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/pause.text = (
		"Resume" if get_tree().paused else "Pause"
	)


func _on_console_pressed():
	var console = get_tree().get_nodes_in_group("console")[0]
	console.visible = not console.visible
	$HUD/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/console.text = (
		"Hide Console" if console.visible else "Show Console"
	)
