extends Node2D


@onready var body = $CharacterBody2D
@onready var shape = $CharacterBody2D/CollisionShape2D
@onready var interactive_area = $CharacterBody2D/InteractiveArea2D

var lift_transformer = null


func _on_interactive_area_2d_area_entered(area):
	lift_transformer = area.get_node("GrabbingRemoteTransform2D")
	set_multiplayer_authority(area.get_multiplayer_authority())


func _on_interactive_area_2d_interacted():
	lift_transformer.remote_path = lift_transformer.get_path_to(body)
