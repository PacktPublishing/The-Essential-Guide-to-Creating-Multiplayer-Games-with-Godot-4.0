extends Control

const ADDRESS = "127.0.0.1"
const PORT = 9999

@onready var texture_rect = $AvatarCard/TextureRect
@onready var label = $AvatarCard/Label


func _ready():
	var packet = PacketPeerUDP.new()
	packet.connect_to_host(ADDRESS, PORT)
	request_authentication(packet)


func request_authentication(packet):
	var request = {'get_authentication_token': true, "user": AuthenticationCredentials.user, "token": AuthenticationCredentials.session_token}
	packet.put_var(JSON.stringify(request))

	while packet.wait() == OK:
		var data = JSON.parse_string(packet.get_var())
		if data == AuthenticationCredentials.session_token:
			request_avatar(packet)
			break


func request_avatar(packet):
	var request = {'get_avatar': true, 'token': AuthenticationCredentials.session_token, "user": AuthenticationCredentials.user}
	packet.put_var(JSON.stringify(request))
	
	while packet.wait() == OK:
		var data = JSON.parse_string(packet.get_var())
		if "avatar" in data:
			var texture = load(data['avatar'])
			texture_rect.texture = texture
			label.text = data['name']
			break
