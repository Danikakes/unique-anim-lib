@tool
extends EditorInspectorPlugin

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

	var button: Button = Button.new()
	button.text = "Make Embedded Libraries Unique"
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Duplicates built-in animation libraries on this AnimationPlayer so copies stop sharing them."

	if embedded_count > 1:
		var header: Label = Label.new()
		header.text = "Multiple Libraries Detected. Select which to make unique."
		header.label_settings = LabelSettings.new()
		header.label_settings.font_size = 14
		header.autowrap_mode = TextServer.AUTOWRAP_WORD
		container.add_child(header)

		var checkboxes: Array[CheckBox] = []

		for library_key in embedded_keys:
			var checkbox: CheckBox = CheckBox.new()
			checkbox.text = _get_library_label(library_key)
			checkbox.button_pressed = true
			checkbox.toggled.connect(_update_button_disabled_state.bind(button, checkboxes))
			checkboxes.append(checkbox)
			container.add_child(checkbox)

		container.add_child(button)
		button.pressed.connect(_on_make_unique_pressed.bind(player, embedded_keys, checkboxes))
		_update_button_disabled_state(button, checkboxes)
	else:
		container.add_child(button)
		button.disabled = embedded_count == 0
		button.pressed.connect(_plugin.make_embedded_libraries_unique.bind(player))

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
			return

	button.disabled = true


func _get_library_label(library_key: String) -> String:
	if library_key.is_empty():
		return "Default Library"

	return library_key
