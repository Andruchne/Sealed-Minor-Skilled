extends Resource
class_name MemoryObject

@export var current_level : String = ""

# Temporarily holds items
@export var cobweb : bool

# Player memory
@export var alt_color : bool

# General memory
var knows_cobweb : bool
var squeezed_gap : bool
var knows_interact : bool

# Actual memory of actions
@export var dirr_look_back : bool
@export var dirr_nothing : bool
@export var dirr_prepare_snack : bool
@export var dirr_ugly : bool
@export var dirr_important : bool
@export var dirr_follow_player : bool

@export var dirr_collected_cobweb : bool

@export var window_race : bool
@export var dirr_first_arrived : bool

@export var dirr_offended : bool

# Environmental
@export var sc0_gate_open : bool
@export var sc2_gate_open_0 : bool
@export var sc2_gate_open_1 : bool

# Soul actions
@export var soul_intro_played : bool
@export var soul_green_guide : bool
@export var soul_green_hit_once : bool
@export var soul_warned_trace : bool
@export var soul_first_win : bool
@export var soul_intro_second_try : bool

# Temp memory, just for faster coding
@export var dirr_spawned_01 : bool
@export var dirr_spawned_02 : bool
@export var dirr_spawned_03 : bool
@export var dirr_go_home : bool

@export var dirr_at_0 : bool
@export var dirr_at_1 : bool = true
@export var dirr_at_2 : bool

func check_memory(entry : String) -> bool:
	var result : bool = get(entry)
	if result != null:
		return result
	else:
		return false


func set_memory(entry : String, state : bool) -> void:
	if get(entry) != null:
		set(entry, state)
