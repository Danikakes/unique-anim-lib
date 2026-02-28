@tool
extends EditorPlugin

const AnimationPlayerInspectorPlugin = preload("res://addons/unique_anim_lib/animation_player_inspector_plugin.gd")

var _inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	_inspector_plugin = AnimationPlayerInspectorPlugin.new(self)
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	if _inspector_plugin != null:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null


func get_embedded_library_count(player: AnimationPlayer) -> int:
	var count := 0

	for library_key in player.get_animation_library_list():
		var library := player.get_animation_library(library_key)
		if _is_embedded_resource(library):
			count += 1

	return count


func get_embedded_library_keys(player: AnimationPlayer) -> PackedStringArray:
	var keys := PackedStringArray()

	for library_key in player.get_animation_library_list():
		var library := player.get_animation_library(library_key)
		if _is_embedded_resource(library):
			keys.append(String(library_key))

	return keys


func make_embedded_libraries_unique(
	player: AnimationPlayer,
	selected_keys: PackedStringArray = PackedStringArray()
) -> void:
	var replacements := _build_library_replacements(player, selected_keys)
	if replacements.is_empty():
		return

	var undo_redo := get_undo_redo()
	undo_redo.create_action("Make Embedded Animation Libraries Unique")

	for replacement in replacements:
		undo_redo.add_do_method(
			self,
			"_replace_animation_library",
			player,
			replacement["key"],
			replacement["new_library"]
		)

	for replacement in replacements:
		undo_redo.add_undo_method(
			self,
			"_replace_animation_library",
			player,
			replacement["key"],
			replacement["old_library"]
		)

	undo_redo.add_do_method(self, "_refresh_editor_state", player)
	undo_redo.add_undo_method(self, "_refresh_editor_state", player)
	undo_redo.commit_action()


func _build_library_replacements(
	player: AnimationPlayer,
	selected_keys: PackedStringArray
) -> Array[Dictionary]:
	var replacements: Array[Dictionary] = []
	var limit_to_selection := not selected_keys.is_empty()

	for library_key in player.get_animation_library_list():
		var library := player.get_animation_library(library_key)
		if not _is_embedded_resource(library):
			continue

		if limit_to_selection and not selected_keys.has(String(library_key)):
			continue

		var duplicated_library := library.duplicate_deep(Resource.DEEP_DUPLICATE_INTERNAL) as AnimationLibrary
		if duplicated_library == null:
			continue

		replacements.append(
			{
				"key": library_key,
				"old_library": library,
				"new_library": duplicated_library,
			}
		)

	return replacements


func _is_embedded_resource(resource: Resource) -> bool:
	if resource == null:
		return false

	return resource.resource_path.is_empty() or resource.resource_path.contains("::")


func _replace_animation_library(
	player: AnimationPlayer,
	library_key: StringName,
	library: AnimationLibrary
) -> void:
	if player == null:
		return

	if player.has_animation_library(library_key):
		player.remove_animation_library(library_key)

	player.add_animation_library(library_key, library)


func _refresh_editor_state(player: AnimationPlayer) -> void:
	if player == null:
		return

	player.notify_property_list_changed()
	get_editor_interface().mark_scene_as_unsaved()
