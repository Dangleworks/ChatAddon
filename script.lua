chatbot_port = 9005
steam_ids = {}

function onCreate(is_world_create)
	for _, player in pairs(server.getPlayers()) do
		steam_ids[player.id] = tostring(player.steam_id)
	end
	server.httpGet(chatbot_port, "/getmsgs")
end

function httpReply(port, url, response_body)
	if url == "/getmsgs" and response_body ~= "Connection closed unexpectedly" then
		pos = string.find(response_body,"\r")
		if pos ~= nil then
			name = string.sub(response_body,0,pos)
			msg = string.sub(response_body,pos,string.len(response_body))
			server.announce(name, msg)
		end
	end
	server.httpGet(chatbot_port, "/getmsgs")
end

function onPlayerJoin(steam_id, name, peer_id, admin, auth)
	steam_ids[peer_id] = tostring(steam_id)
end

function onChatMessage(user_peer_id, sender_name, message)
	server.httpGet(chatbot_port, "/sendmsg?msg="..encode(message).."&sid="..encode(steam_ids[user_peer_id]))
end

function encode(str)
	if str == nil then
		return ""
	end
	str = string.gsub(str, "([^%w _ %- . ~])", cth)
	str = str:gsub(" ", "%%20")
	return str
end

function cth(c)
	return string.format("%%%02X", string.byte(c))
end