extends Resource
class_name GameSaveData

@export var save_index : int

@export var save_name : String
@export var spent_time : String
@export var player_info : PlayerInfo = PlayerInfo.new()

@export var scene_name : String
# Data of current level
@export var level_data : LevelData = LevelData.new()
# Memory of previously visited levels
@export var level_memory : Dictionary[String, LevelData]
@export var memory : MemoryObject
