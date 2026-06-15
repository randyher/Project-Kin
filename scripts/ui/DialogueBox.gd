class_name DialogueBox
extends CanvasLayer

## Emitted once the player has advanced past the final line.
signal dialogue_finished

@onready var _name_label: Label = $Panel/NameLabel
@onready var _text_label: Label = $Panel/TextLabel

var _lines: Array[String] = []
var _index: int = 0
## Process frame on which the dialogue opened — input is ignored until the
## next frame so the press that opened the box doesn't also advance it.
var _opened_frame: int = -1


func _ready() -> void:
	visible = false


func start_dialogue(lines: Array[String], speaker: String) -> void:
	_lines = lines
	_index = 0
	_name_label.text = speaker
	_opened_frame = Engine.get_process_frames()

	if _lines.is_empty():
		_finish()
		return

	_text_label.text = _lines[0]
	visible = true


func _process(_delta: float) -> void:
	if not visible:
		return
	if Engine.get_process_frames() == _opened_frame:
		return
	if not Input.is_action_just_pressed("p1_square"):
		return

	_index += 1
	if _index >= _lines.size():
		_finish()
	else:
		_text_label.text = _lines[_index]


func _finish() -> void:
	visible = false
	dialogue_finished.emit()
