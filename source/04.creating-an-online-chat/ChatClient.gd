extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@export var avatar_card_scene = preload("res://03.making-lobby-to-gather-players/AvatarCard.tscn")

@onready var avatar_card_container = $AvatarCardsScrollContainer/AvatarCardsHBoxContainer
@onready var chat = $ChatControl

var peer = ENetMultiplayerPeer.new()


func _ready():
	var authority_id = get_multiplayer_authority() 
	rpc_id(authority_id, "retrieve_avatar", AuthenticationCredentials.user, AuthenticationCredentials.session_token)


@rpc
func add_avatar(avatar_name, texture_path):
	var avatar_card = avatar_card_scene.instantiate()
	avatar_card_container.add_child(avatar_card)
	await(get_tree().process_frame)
	avatar_card.update_data(avatar_name, texture_path)


@rpc
func clear_avatars():
	for child in avatar_card_container.get_children():
		child.queue_free()


@rpc
func retrieve_avatar(user, session_token):
	pass


@rpc
func authenticate_player(user, password):
	pass


@rpc
func authentication_failed(error_message):
	pass


@rpc
func authentication_succeed(user, session_token):
	pass
