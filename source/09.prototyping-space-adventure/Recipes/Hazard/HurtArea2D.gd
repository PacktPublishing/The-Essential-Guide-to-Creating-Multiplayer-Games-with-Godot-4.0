class_name HurtArea2D
extends Area2D

signal damage_taken(damage)

enum TEAM {Player, Enemy, Neutral}

@export var defense = 0
@export var team: TEAM = TEAM.Player


func take_damage(hit_area):
	if not hit_area.team == team:
		damage_taken.emit(hit_area.damage - defense)
