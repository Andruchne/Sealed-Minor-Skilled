@tool
@icon('TileMapDual.svg')
class_name TileMapDual
extends TileMapLayer

var _tileset_watcher: TileSetWatcher
var _display: Display

func _ready() -> void:
	_tileset_watcher = TileSetWatcher.new(tile_set)
	_display = Display.new(self, _tileset_watcher)
	add_child(_display)
	_make_self_invisible()

	if Engine.is_editor_hint():
		_tileset_watcher.atlas_autotiled.connect(_atlas_autotiled, 1)
		set_process(true)
	else:
		set_process(false)
		changed.connect(_changed, 1)

	await get_tree().process_frame
	_changed()


# Called only inside editor when atlas is auto-generated
func _atlas_autotiled(source_id: int, atlas: TileSetAtlasSource) -> void:
	if Engine.is_editor_hint():
		# NOTE: This only works correctly inside an EditorPlugin.
		# If you're calling this from a plugin, pass the correct undo_redo manager.
		printerr("TileMapDual: write_default_preset() skipped — requires EditorUndoRedoManager.")
		# To properly support undo, integrate this code in an EditorPlugin class.


## Hides the base TileMapLayer so only DisplayLayer shows tiles
func _make_self_invisible() -> void:
	if material != null:
		return
	material = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY


## How often to refresh in the editor (used with _process)
@export_range(0.0, 0.1) var refresh_time: float = 0.02
var _timer: float = 0.0

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	if refresh_time < 0.0:
		return
	if _timer > 0.0:
		_timer -= delta
		return
	_timer = refresh_time
	call_deferred("_changed")


## Called when the tileset changes
func _changed() -> void:
	_tileset_watcher.update(tile_set)
 

## Called when user draws or uses undo/redo
func _update_cells(coords: Array[Vector2i], forced_cleanup: bool) -> void:
	if _display != null:
		_display.update(coords)


## Public API: draws terrain at cell (removes tile if terrain not found)
func draw_cell(cell: Vector2i, terrain: int = 1) -> void:
	var terrains := _display.terrain.terrains
	if terrain not in terrains:
		erase_cell(cell)
		changed.emit()
		return
	var tile_to_use: Dictionary = terrains[terrain]
	var sid: int = tile_to_use.sid
	var tile: Vector2i = tile_to_use.tile
	set_cell(cell, sid, tile)
	changed.emit()


## Public API: returns terrain value at a specific coordinate
func get_cell(cell: Vector2i) -> int:
	return get_cell_tile_data(cell).terrain
