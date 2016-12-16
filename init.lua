
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

-- helper functions
local function facedir_to_look_horizontal(dir)
	if dir == 0 then
		return 0
	elseif dir == 1 then
		return math.pi * 3/2
	elseif dir == 2 then
		return math.pi
	elseif dir == 3 then
		return math.pi / 2
	else
		return nil
	end
end

local function vector_rotate_xz(vec, angle)
	local a = angle - (math.pi * 3/2)
	return {
		x = (vec.z * math.sin(a)) - (vec.x * math.cos(a)),
		y = vec.y,
		z = (vec.z * math.cos(a)) - (vec.x * math.sin(a))
	}
end

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

function emote.attach_to_node(player, pos)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		return false
	end

	local def = minetest.registered_nodes[node.name].emote or {}

	local emotedef = {
		eye_offset = def.eye_offset or {x = 0, y = 1/2, z = 0},
		player_offset = def.player_offset or {x = 0, y = 0, z = 0},
		look_horizontal_offset = def.look_horizontal_offset or 0,
		emotestring = def.emotestring or "sit",
	}

	player:setpos(vector.add(pos, vector_rotate_xz(emotedef.player_offset, facedir_to_look_horizontal(node.param2))))
	player:set_eye_offset(emotedef.eye_offset, {x = 0, y = 0, z = 0})
	player:set_look_horizontal(facedir_to_look_horizontal(node.param2) + emotedef.look_horizontal_offset)
	player:set_animation(unpack(emotes[emotedef.emotestring]))
	player:set_physics_override(0, 0, 0)
end

function emote.attach_to_entity(player, emotestring, obj)
	-- not implemented yet.
end

function emote.detach(player)
	-- check if attached?
	player:set_eye_offset(vector.new(), vector.new())
	player:set_physics_override(1, 1, 1)
	player:set_animation(unpack(emotes["stand"]))
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

--[[
-- testing tool - punch any node to test attachment code
minetest.register_craftitem("emote:sleep", {
	description = "use me on a bed bottom",
	on_use = function(itemstack, user, pointed_thing)
		-- the delay here is weird, but the client receives a mouse-up event
		-- after the punch and switches back to "stand" animation, undoing
		-- the animation change we're doing.
		minetest.after(0.5, emote.attach_to_node, user, pointed_thing.under)
	end
})
]]--
