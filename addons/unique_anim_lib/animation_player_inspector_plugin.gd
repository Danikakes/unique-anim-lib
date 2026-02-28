@tool
extends EditorInspectorPlugin

const ENABLED_TOOLTIP := "Duplicates built-in animation libraries on this AnimationPlayer so copies stop sharing them."
const DISABLED_TOOLTIP := "There are no libraries to copy."

var _plugin


func _init(plugin: EditorPlugin) -> void:
	_plugin = plugin


func _can_handle(object: Object) -> bool:
	return object is AnimationPlayer


func _parse_begin(object: Object) -> void:
	var player: AnimationPlayer = object as AnimationPlayer
	var embedded_keys: PackedStringArray = _plugin.get_embedded_library_keys(player)
	var embedded_count: int = embedded_keys.size()

	var container := VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var dropdown_button := Button.new()
	dropdown_button.text = _get_dropdown_title(embedded_count, false)
	dropdown_button.toggle_mode = true
	dropdown_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	dropdown_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(dropdown_button)

	var content := VBoxContainer.new()
	content.visible = false
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(content)

	var button: Button = Button.new()
	button.text = "Make Embedded Libraries Unique"
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = ENABLED_TOOLTIP

	if embedded_count > 1:
		var header: Label = Label.new()
		header.text = "Multiple Libraries Detected. Select which to make unique."
		header.label_settings = LabelSettings.new()
		header.label_settings.font_size = 14
		header.autowrap_mode = TextServer.AUTOWRAP_WORD
		content.add_child(header)

		var checkboxes: Array[CheckBox] = []

		for library_key in embedded_keys:
			var checkbox: CheckBox = CheckBox.new()
			checkbox.text = _get_library_label(library_key)
			checkbox.button_pressed = true
			checkboxes.append(checkbox)
			checkbox.toggled.connect(_on_checkbox_toggled.bind(button, checkboxes))
			content.add_child(checkbox)

		content.add_child(button)
		button.pressed.connect(_on_make_unique_pressed.bind(player, embedded_keys, checkboxes))
		_update_button_disabled_state(button, checkboxes)
	else:
		content.add_child(button)
		button.disabled = embedded_count == 0
		button.tooltip_text = DISABLED_TOOLTIP if button.disabled else ENABLED_TOOLTIP
		button.pressed.connect(_plugin.make_embedded_libraries_unique.bind(player))

	dropdown_button.toggled.connect(_on_dropdown_toggled.bind(dropdown_button, content, embedded_count))
	add_custom_control(container)


func _on_make_unique_pressed(
	player: AnimationPlayer,
	library_keys: PackedStringArray,
	checkboxes: Array[CheckBox]
) -> void:
	var selected_keys := PackedStringArray()

	for index in range(library_keys.size()):
		if checkboxes[index].button_pressed:
			selected_keys.append(library_keys[index])

	if selected_keys.is_empty():
		return

	_plugin.make_embedded_libraries_unique(player, selected_keys)


func _update_button_disabled_state(button: Button, checkboxes: Array[CheckBox]) -> void:
	for checkbox in checkboxes:
		if checkbox.button_pressed:
			button.disabled = false
			button.tooltip_text = ENABLED_TOOLTIP
			return

	button.disabled = true
	button.tooltip_text = DISABLED_TOOLTIP


func _on_checkbox_toggled(
	_is_checked: bool,
	button: Button,
	checkboxes: Array[CheckBox]
) -> void:
	_update_button_disabled_state(button, checkboxes)


func _on_dropdown_toggled(
	is_expanded: bool,
	dropdown_button: Button,
	content: Control,
	embedded_count: int
) -> void:
	content.visible = is_expanded
	dropdown_button.text = _get_dropdown_title(embedded_count, is_expanded)


func _get_dropdown_title(embedded_count: int, is_expanded: bool) -> String:
	var prefix := "▼" if is_expanded else "▲"
	return "%s Animation Libraries (%d)" % [prefix, embedded_count]


func _get_library_label(library_key: String) -> String:
	if library_key.is_empty():
		return "Default Library"

	return library_key
