local constants = require('imposter.constants')
local utils		= require('imposter.util')

local dap		= require('dap')



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


	vim.ui.select(configurations, {
		prompt = 'Select conf:',
		format_item = function(conf)
			return  vim.inspect(conf['name'])
		end,
	}, function(choice)

		if  not choice then
			return
		end
		local config = utils.format_config(choice)

		dap.run(config)
	end)

end

return M
