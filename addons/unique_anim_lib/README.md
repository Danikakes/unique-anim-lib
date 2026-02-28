# Unique Animation Libraries

Godot editor plugin that adds an `AnimationPlayer` inspector action for making embedded `AnimationLibrary` resources unique.

This is useful when duplicated scenes or nodes still share built-in animation libraries and you want each copy to own its own editable animation data.

## What It Does

- Adds a `Make Embedded Libraries Unique` button to the inspector for every `AnimationPlayer`.
- Detects embedded animation libraries on that player.
- If multiple embedded libraries are present, shows a checkbox list so you can choose which ones to duplicate.
- Replaces the selected libraries with deep-duplicated copies.
- Registers the change through Godot's undo/redo system.

Only embedded libraries are affected. External `.tres` or `.res` animation libraries are left alone.

## Installation

1. Copy `addons/unique_anim_lib` into your Godot project's `addons/` folder.
2. Open the project in Godot.
3. Go to `Project > Project Settings > Plugins`.
4. Enable `Unique Animation Libraries`.

## Usage

1. Select a node with an `AnimationPlayer`.
2. In the inspector, find the plugin section with the `Make Embedded Libraries Unique` button.
3. If the player has more than one embedded library, choose the libraries you want to duplicate.
4. Click the button.

After the action runs, the selected embedded libraries are replaced with unique copies on that `AnimationPlayer`.

## When To Use It

Use this plugin when:

- you duplicated a scene or node and its animations are still linked through embedded resources
- editing one animation library unexpectedly changes another instance
- you want to break sharing without manually rebuilding animation libraries

## Notes

- The included sample project is configured for Godot `4.6`.
- The plugin works on `AnimationPlayer` inspector objects only.
- Changes mark the scene as modified so they can be saved normally.
- Undo/redo is supported from the editor.

## Demo Project

This repository includes a small sample scene at [`addons/demo/demo.tscn.tscn`](addons/demo/demo.tscn.tscn) with embedded animation libraries you can use to verify the plugin behavior in the editor.

## Repository Layout

- [`addons/unique_anim_lib/plugin.cfg`](addons/unique_anim_lib/plugin.cfg) contains the plugin metadata.
- [`addons/unique_anim_lib/plugin.gd`](addons/unique_anim_lib/plugin.gd) handles library detection, duplication, and undo/redo.
- [`addons/unique_anim_lib/animation_player_inspector_plugin.gd`](addons/unique_anim_lib/animation_player_inspector_plugin.gd) adds the inspector UI for `AnimationPlayer`.

## License

[`MIT`](LICENSE)
