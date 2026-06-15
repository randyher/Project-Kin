## DialogueManager.gd
## Global singleton — registered in Project → Project Settings → Autoload as "DialogueManager".
##
## Every NPC registers/unregisters itself (via register_npc/unregister_npc)
## when the player enters/exits its InteractionZone, so dropping a new
## NPC.tscn into any room requires no extra wiring. DialogueManager owns the
## single shared DialogueBox UI, freezes all players for the duration of the
## conversation, and unfreezes them once the player has stepped through every
## line.
##
## The p1_square trigger is polled here, in _physics_process(), rather than
## in NPC.gd. Autoloads always run their _physics_process before the main
## scene tree each frame, which guarantees dialogue_locked is set on Player
## BEFORE Player._get_input() runs on the same physics step — otherwise the
## opening press would also register as an attack.

extends Node

const DialogueBoxScene := preload("res://scenes/ui/DialogueBox.tscn")

var _dialogue_box: DialogueBox
var _active: bool = false
var _npcs_in_range: Array[NPC] = []


func _ready() -> void:
	_dialogue_box = DialogueBoxScene.instantiate()
	add_child(_dialogue_box)
	_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)


func is_active() -> bool:
	return _active


func register_npc(npc: NPC) -> void:
	if not _npcs_in_range.has(npc):
		_npcs_in_range.append(npc)


func unregister_npc(npc: NPC) -> void:
	_npcs_in_range.erase(npc)


func _physics_process(_delta: float) -> void:
	if _active or _npcs_in_range.is_empty():
		return
	if Input.is_action_just_pressed("p1_square"):
		var npc: NPC = _npcs_in_range[0]
		_active = true
		_set_players_locked(true)
		_dialogue_box.start_dialogue(npc.dialogue_lines, npc.npc_name)


func _on_dialogue_finished() -> void:
	_active = false
	_set_players_locked(false)


func _set_players_locked(locked: bool) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		player.dialogue_locked = locked
