extends CharacterBody2D
class_name Player

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var frutas_label: Label = $PlayerGUI/HBoxContainer/FrutasLabel
@onready var raycast_dmg: Node2D = $RaycastDmg

var speed :int=120
var direction :=0.0
var jump :=250
const gravity :=9
#攻击伤害
var damage = 1

#两个状态，正常、受伤
enum status {NORMAL,INJURED}
var statusCurrent = status.NORMAL

#hp
var vita := 10 :
	set(val):
		vita =val
		$PlayerGUI/HpProgressBar.value=vita

func _ready() -> void:
	#初始化血量
	$PlayerGUI/HpProgressBar.value = vita
	#全局
	Global.player = self


func _physics_process(delta: float) -> void:
	if statusCurrent == status.NORMAL:
		processNormal(delta)
	
#玩家正常状态
func processNormal(delta: float) -> void:
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
					
			
			
#受伤			
func takeDamage(dmg):
	#只有没受伤状态可以掉血
	if statusCurrent !=status.INJURED:
		#计算血量
		vita = vita-dmg
		animation_player.play("injured")
		$ClodDownTimer.start()
		statusCurrent = status.INJURED
		print(vita)
		if vita<=0:
			die()
	
#死亡重新加载，避免一个警告
func die():
	#get_tree().reload_current_scene()
	call_deferred("reload_scene")	
	
#回到开始地点	
func reload_scene():
	get_tree().reload_current_scene()
				
			
#标签文字展示	
func actualizaInterfazFrutas():
	frutas_label.text = str(Global.frutas)


#受伤状态恢复到正常
func _on_clod_down_timer_timeout() -> void:
	statusCurrent =status.NORMAL
