extends Area2D

signal damage_applied(damage)

enum TEAM {Player, Enemy, Neutral}

@export var damage = 1
@export var team: TEAM = TEAM.Player


func apply_damage(hurt_area):
	if not hurt_area.team == team:
		hurt_area.take_damage(self)
		damage_applied.emit(damage - hurt_area.defense)


func _on_area_entered(area):
	apply_damage(area)
