extends Node2D

var positions = ["E", "NE", "N", "NW", "W", "SW", "S", "SE"]

export var distance = 50.0

export var damage = 5
export var attack_rate = 0.3
var attack_time = 0

onready var sprite = $Skull
onready var animation = $Skull/AnimationPlayer

var direction = Vector2(0, 0)
var aim_direction = Vector2(1, 0)
var facing = "E"
var shooting = false

var sword_scene = preload("res://Player/Melee/Sword.tscn")

func _process(delta):
  attack_time -= delta
  aim()

func aim():
  if !Game.scene.player.alive:
    return

  if Game.mouse_active:
    aim_direction = (
        Game.scene.get_global_mouse_position() +\
        Vector2(0, 40) -\
        Game.scene.player.global_position\
        ).normalized()
  elif Game.joy_aim_direction.length_squared() > 0:
    aim_direction = Game.joy_aim_direction

  position = aim_direction * distance
  var angle = aim_direction.angle()
  var angle_rad = angle + PI + PI / 8
  var angle_ratio = angle_rad / (TAU + PI / 8)
  var anim_index = angle_ratio * positions.size()

  if Input.is_action_just_pressed("melee") && attack_time <= 0:
    attack_time = attack_rate
    spawn_sword()

  facing = positions[int(anim_index)]

  var anim = facing
  if shooting:
    anim = "%s%s" % [facing, "Attack"]
  animation.play(anim)

func spawn_sword():
  var sword = sword_scene.instance()
  Game.scene.bodies.call_deferred("add_child", sword)
  sword.rotation = aim_direction.angle()
  sword.global_position = global_position
