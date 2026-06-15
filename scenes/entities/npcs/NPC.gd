class_name NPC
extends StaticBody2D

## Lines shown one at a time when the player talks to this NPC.
## Set per-instance in the Inspector — no script changes needed.
@export var dialogue_lines: Array[String] = []
## Name shown as the speaker label in the dialogue box.
@export var npc_name: String = "NPC"

## Radius (px) of the zone the player must stand in to start dialogue.
@export_range(8.0, 300.0, 1.0, "suffix:px") var interaction_radius: float = 90.0
## Position of the "press square" prompt relative to the NPC's origin.
## Negative y = above the NPC's head.
@export var prompt_offset: Vector2 = Vector2(0, -56)

@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_zone_shape: CollisionShape2D = $InteractionZone/CollisionShape2D
@onready var _interaction_prompt: Sprite2D = $InteractionPrompt


func _ready() -> void:
	_interaction_zone.body_entered.connect(_on_body_entered)
	_interaction_zone.body_exited.connect(_on_body_exited)

	var shape: CircleShape2D = _interaction_zone_shape.shape.duplicate()
	shape.radius = interaction_radius
	_interaction_zone_shape.shape = shape

	_interaction_prompt.position = prompt_offset


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_interaction_prompt.visible = true
		DialogueManager.register_npc(self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_interaction_prompt.visible = false
		DialogueManager.unregister_npc(self)
