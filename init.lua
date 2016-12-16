
--[[

Copyright (C) 2016 - Auke Kok <sofar@foo-projects.org>

"emote" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

]]--

emote = {}

local emotes = {
	stand  = {{x =   0, y =  79}, 30, 0, true},
	sit    = {{x =  81, y = 160}, 30, 0, true},
	lay    = {{x = 162, y = 166}, 30, 0, true},
	sleep  = {{x = 162, y = 166}, 30, 0, true}, -- alias for lay
	wave   = {{x = 192, y = 196}, 15, 0, false},
	point  = {{x = 196, y = 196}, 30, 0, true},
	freeze = {{x = 205, y = 205}, 30, 0, true},
}

local emoting = {}

function emote.start(player, emotestring)
	emote.stop(player)
	if emotes[emotestring] then
		player:set_animation(unpack(emotes[emotestring]))
		emoting[player] = emotestring
		local e = emotes[emotestring]
		if not e[4] then
			local len = (e[1].y - e[1].x) / e[2]
			minetest.after(len, emote.stop, player)
		end
		return true
	else
		return false
	end
end

function emote.stop(player)
	if emoting[player] then
		emoting[player] = nil
		player:set_animation(unpack(emotes["stand"]))
	end
end

function emote.list()
	local r = {}
	for k, _ in pairs(emotes) do
		table.insert(r, k)
	end
	return r
end

for k, _ in pairs(emotes) do
	minetest.register_chatcommand(k, {
		params = k .. " emote",
		description = "Makes your character perform the " .. k .. " emote",
		func = function(name, param)
			local player = minetest.get_player_by_name(name)
			emote.start(player, k)
		end,
	})
end
