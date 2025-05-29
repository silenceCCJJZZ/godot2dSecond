extends CharacterBody2D
class_name Player

var speed :int=120
var direction :=0.0
var jump :=250
const gravity :=9
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var frutas_label: Label = $PlayerGUI/HBoxContainer/FrutasLabel



func _ready() -> void:
	Global.player = self


func _physics_process(delta: float) -> void:
	direction = Input.get_axis("ui_left","ui_right")
	velocity.x = direction * speed
	
	#方向 -1，0，1，根据方向播放动作
	if direction !=0:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	
	#调整人物翻转
	if direction>0:
		sprite.flip_h=false
	elif direction<0:
		sprite.flip_h=true
	
	
	if is_on_floor() and  Input.is_action_just_pressed("ui_accept") :
		velocity.y -= jump
	if !is_on_floor():
		velocity.y +=gravity
	
	move_and_slide()
	

	
func actualizaInterfazFrutas():
	frutas_label.text = str(Global.frutas)
