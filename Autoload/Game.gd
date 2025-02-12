extends Node

var scene:Node

#warning-ignore:unused_class_variable
var high_score = 0
var target_scene

var mouse_active = false
var joy_aim_direction setget ,get_joy_aim_direction
var dead_zone = 0.4

var _aim = Vector2(0, 0)

onready var dead_zone_squared = dead_zone * dead_zone

var mouse_position_was = null
var mouse_wait_time = 1

func initialize():
  scene = $'../World'

func _ready():
  randomize()
  Overlay.connect("fade_complete", self, "_on_Overlay_fade_complete")
  Transition.connect("transition_complete", self, "_on_Transition_complete")
  Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
  var mouse_position = get_viewport().get_mouse_position()

  _aim = Vector2(
      Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
      Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")\
      )

  var move_direction = Vector2(0, 0)
  move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
  move_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

  if mouse_wait_time > 0:
    mouse_wait_time -= delta
  elif mouse_position_was != mouse_position || kb_move_pressed():
    mouse_active = true
  elif self.joy_aim_direction.length_squared() > 0 || move_direction.length_squared() > dead_zone_squared:
    mouse_active = false

  mouse_position_was = mouse_position

func kb_move_pressed():
  for direction in ["left", "right", "up", "down"]:
    if Input.is_action_pressed("kb_move_%s" % direction):
      return true

  return false

func reset():
  Game.change_scene("res://Scenes/Gameplay.tscn", false)

func change_scene(new_scene, fade_music = true):
  target_scene = new_scene
  # Overlay.fade(Color(0, 0, 0, 0), Color(0, 0, 0, 1), 0.3)
  Transition.transition_out()

  if fade_music:
    MusicPlayer.fade(MusicPlayer.music_volume, -80, 0.3)

func _on_Transition_complete():
  if target_scene != null:
    var scene = target_scene
    target_scene = null
    yield(get_tree().create_timer(0.5), "timeout")
    get_tree().change_scene(scene)
    Transition.transition_in()
    MusicPlayer.fade(MusicPlayer.music_volume, 0, 0.2)
    MusicPlayer.disable_filter()

func _on_Overlay_fade_complete():
  pass

func get_joy_aim_direction():
  if _aim.length_squared() > dead_zone_squared:
    return _aim.normalized()
  else:
    return Vector2(0, 0)
