tool
extends EditorPlugin

var hover_wait_time: = 0.5

var is_mouse_pressed: = false
var is_waiting: = false
var recent_pos: = Vector2.ZERO

var timer: = Timer.new()

func _input(event):
	if event is InputEventMouseMotion:
		if !event.button_mask: return
		timer.start()
		recent_pos = event.global_position



func _enter_tree():
	timer.wait_time = hover_wait_time
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", self, "on_timeout", [get_editor_interface().get_base_control()])
	

func _exit_tree():
	pass

func on_timeout(base_control: Control):
	if !base_control.get_global_mouse_position() ==recent_pos: return
	var inspector_section:Control = get_inspector_section_at_mouse()
	if not inspector_section: return
	
	inspector_section.unfold()

# todo: could be optimized
func get_inspector_section_at_mouse()->Control:
	var section_control:Control
	var inspector_child:Control = get_editor_interface().get_inspector().get_child(0)
	var mouse_pos: = inspector_child.get_global_mouse_position()
	
	if !inspector_child.get_global_rect().has_point(mouse_pos):
		return section_control
	for section in get_nodes_by_class(inspector_child, 'EditorInspectorSection'):
		section = section as Control

		if section.get_global_rect().has_point(mouse_pos):
			section_control = section
	return section_control


static func get_nodes_by_class(node:Node, cls)->Array:
	var res:= []
	var nodes = []
	var stack = [node]
	while stack:
		var n = stack.pop_back()
		if n.get_class() ==cls:
			res.push_back(n)
		nodes.push_back(n)
		stack.append_array(n.get_children())
	return res
