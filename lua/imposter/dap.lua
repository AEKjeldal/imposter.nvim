local constants     = require('imposter.constants')
local utils		    = require('imposter.util')

local dap		    = require('dap')
local event_handler = require('imposter.event_handler')



local function dap_running()
	local sessions = dap.sessions()
	return not (sessions == nil or next(sessions) == nil)
end


local function get_configurations()
	local launch_config = utils.copy(constants.launch_config)
	for _,ft in pairs(dap.configurations) do
		for _,conf in pairs(ft) do
			table.insert(launch_config,conf)
		end
	end
	return launch_config
end

local function select_configuration()



end


local last_config = nil
local M = {}

M.continue = function()
	-- if nothing is running we want to select and start a config
	-- otherwise we dap.continue()

	vim.notify("Dap status: "..vim.inspect(dap.status()))

	if dap_running() then
		dap.continue()
	else
		local selection = {}

		local configurations = get_configurations()

		local content = { on_select = function(tbl)
			local choice = tbl[1]
			local config = utils.format_config(choice)

			last_config = config
			dap.run(config)
		end,
		data = configurations or {},
		display = 'name' }

		event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox,content)
	end
end

M.restart = function()
	if dap_running() then
		dap.run_last()
	else
		dap.restart()
	end

end



return M
