local constants     = require('imposter.constants')
local utils		    = require('imposter.util')

local dap		    = require('dap')
local event_handler = require('imposter.event_handler')



local function get_configurations()

	local launch_config = utils.copy(constants.launch_config)
	for _,ft in pairs(dap.configurations) do
		for _,conf in pairs(ft) do
			table.insert(launch_config,conf)
		end
	end
	return launch_config
end

local M = {}

M.continue = function()

	local selection = {}
	local configurations = get_configurations()

	local content = { on_select = function(tbl)
		local choice = tbl[1]
		local config = utils.format_config(choice)
		dap.run(config)
	end,
	data = configurations or {},
	display = 'name' }

	event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox,content)

end

return M
