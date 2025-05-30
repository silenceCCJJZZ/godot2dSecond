extends CharacterBody2D
class_name Player

var speed :int=120
var direction :=0.0
var jump :=250
const gravity :=9
#攻击伤害
var damage = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var frutas_label: Label = $PlayerGUI/HBoxContainer/FrutasLabel
@onready var raycast_dmg: Node2D = $RaycastDmg



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
	
func _process(delta: float) -> void:
	#被射线检测到，在敌人组中，跳跃（碰撞检测）移除敌人
	for ray in raycast_dmg.get_children():
		if ray.is_colliding():
			var collision = ray.get_collider()
			if collision.is_in_group("Enemies"):
				if collision.has_method("takeDmg"):
					collision.takeDmg(damage)
					
			
			
			
func takeDamage():
	die()
	
#死亡重新加载
func die():
	get_tree().reload_current_scene()
				
			
#标签文字展示	
func actualizaInterfazFrutas():
	frutas_label.text = str(Global.frutas)
