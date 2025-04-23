extends Resource
class_name GameSaveData

@export var spent_time : String
@export var player_info : PlayerInfo

@export var scene_root : PackedScene
@export var game_object_scenes : Array[PackedScene] = []
@export var game_object_states : Array = []
