extends Node
#存放全局脚本

@onready var frutas_sound: AudioStreamPlayer = $FrutasSound


#更新水果数量
var frutas :=0 :
	set(val):
		frutas = val
		if player !=null:
			player.actualizaInterfazFrutas() #upadteFruits
			frutas_sound.play()
	get:
		return frutas
		
var player
