extends Person

@onready var ray_cast_ground: RayCast2D = $RayCast/RayCastGround
@onready var ray_cast_wall: RayCast2D = $RayCast/RayCastWall
@onready var ray_cast: Node2D = $RayCast
@onready var ray_timer: Timer = $RayCast/RayTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast_player_direction: RayCast2D = $RayCastPlayerDirection
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var dmg_collision_shape: CollisionShape2D = $DmgPlayer/CollisionShape2D


var direction = -1
var canChangeDirection = true  # 是否可以改变方向的标志，初始为 True
var player

#生气、巡逻、垂死状态
enum status {ANGRY,PATROLS,DYING}
var statusCurrent = status.PATROLS


func _ready() -> void:
	animation_player.play("walk")
	speed = 60
	
func _physics_process(delta: float) -> void:
	velocity.x = direction * speed
	#TODO 角色下落，后面改成重力
	if !is_on_floor():
		velocity.y +=9
	move_and_slide()
	

func _process(delta: float) -> void:
	#通过射线检测玩家是否存在
	if player ==null and ray_cast_player_direction.is_colliding():
		#发生碰撞，返回碰撞体
		var collision = ray_cast_player_direction.get_collider()
		#确认碰撞体在player分组里
		if collision.is_in_group("player"):
			player = collision
			statusCurrent = status.ANGRY
	 
	# 如果玩家存在，计算怪物朝向
	if statusCurrent == status.ANGRY and  player != null:
		animation_player.play("runAngry")
		var directionPlayer = global_position.direction_to(player.global_position)
		if directionPlayer.x <0:
			direction =-1
		elif directionPlayer.x >0:
			direction = 1
			
		#改变方向就翻转
		if direction==1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false	
			
	
	if statusCurrent == status.PATROLS:
		#检测碰撞翻转方向 碰到墙或者地面为空时改变方向
		if canChangeDirection and (ray_cast_wall.is_colliding() or !ray_cast_ground.is_colliding()):
			canChangeDirection = false
			ray_timer.start()
			direction *= -1
			ray_cast.scale.x *=-1
				
		#改变方向就翻转
		if direction==1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

#被攻击计算血量
func takeDmg(damage):
	#计算血量
	blood = blood-damage
	#死亡
	if blood<=0:
		statusCurrent = status.DYING
		#人物碰撞死亡，排除跳跃接触导致死亡
		dmg_collision_shape.set_deferred("disabled",true)
		animation_player.play("hurt")
		#敌人被击败时禁用碰撞(延迟禁用)
		collision_shape.set_deferred("disabled",true)
		await(animation_player.animation_finished)
		queue_free()
		
		
		
func _on_ray_timer_timeout() -> void:
	canChangeDirection = true
	pass # Replace with function body.

#碰撞怪物会导致死亡
func _on_dmg_player_body_entered(body: Node2D) -> void:
	if body is Player:
		body.takeDamage()
	pass # Replace with function body.
