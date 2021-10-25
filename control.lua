--control.lua

local hook = nil
local ghost_active = false
local ghost_target = nil
local ghost_hook = nil


script.on_event({defines.events.on_player_pipette},
	function(e)

		local player = game.players[e.player_index]
		local recipe = player.force.recipes[e.item.name]
		local ore_ignores = {
			["iron-ore"] = true,
			["copper-ore"] = true,
			["coal"] = true,
			["stone"] = true
		}

		target = player.selected
		hook = recipe

		if target ~= nil then 
			if settings.global["Better-Q-ore-toggle"].value and ore_ignores[target.name] then
 				player.clean_cursor()	
				error("Invalid target.")
			else	if player.cursor_stack.valid_for_read == false then
					if player.force.recipes[recipe.name].enabled then
						if player.crafting_queue_size == 0 then
							if target.name == "entity-ghost" then
								ghost_active = true
								ghost_target = target
								ghost_hook = recipe
							end
							player.begin_crafting{count=1, recipe=recipe}	
						else	error("Crafting queue active, please wait.")
						end
					else	error("You haven't researched this yet.")	
					end
				elseif target.name == "entity-ghost" then
						if player.can_build_from_cursor{position={target.position.x,target.position.y},direction=target.direction} == false
							then error("Unable to build.")
						else
							player.build_from_cursor{position={target.position.x,target.position.y},direction=target.direction}
						end
						player.clean_cursor()
				end	
			end
		else player.print("NO TARGET")
		end
	end
)

script.on_event({defines.events.on_player_crafted_item},
	function(e)
		local player = game.players[e.player_index]

		if ghost_active == true and ghost_hook == e.recipe and player.cursor_stack.valid_for_read == false then
			player.cursor_stack.set_stack(e.item_stack)
			e.item_stack.count = e.item_stack.count - 1
			if player.can_build_from_cursor{position={ghost_target.position.x,ghost_target.position.y},direction=ghost_target.direction} then
				player.build_from_cursor{position={ghost_target.position.x,ghost_target.position.y},direction=ghost_target.direction}
			else	
				error("Unable to build.")
			end
			ghost_active = false
			ghost_target = nil
			ghost_hook = nil
		elseif hook == e.recipe and player.cursor_stack.valid_for_read == false then
			if e.item_stack.count == 2 then
				e.item_stack.count = e.item_stack.count - 1
				player.cursor_stack.set_stack(e.item_stack)
			else 
				player.cursor_stack.set_stack(e.item_stack)
				e.item_stack.count = e.item_stack.count - 1
			end
			hook = nil
		end
	end
)

script.on_event({defines.events.on_player_cancelled_crafting},
	function(e)
		hook = nil
		ghost_active = false
		ghost_target = nil
		ghost_hook = nil
	end
)

function error(msg)
	game.surfaces.nauvis.create_entity({
        	name="error-msg",
        	position={target.position.x,target.position.y-1},
		text=msg
        	})
end
