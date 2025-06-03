extends Resource
class_name GameSaveData

@export var save_index : int

@export var save_name : String
@export var spent_time : String
@export var player_info : PlayerInfo = PlayerInfo.new()

@export var level_data : LevelData = LevelData.new()
