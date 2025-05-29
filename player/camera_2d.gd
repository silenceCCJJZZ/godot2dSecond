extends Camera2D

func _ready() -> void:
	#镜头不跟随移动
	top_level=true
	#设置y轴偏移量
	global_position.y = 50

func  _process(delta: float) -> void:
	#仅在x轴跟随
	global_position.x= get_parent().global_position.x
