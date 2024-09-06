local utils = require('imposter.util')

local M = {}
M.show_dropdown = function(args)
	local prompt = args.prompt or "Enter Selection: "
	local show = utils.map(function(tbl) return tbl[args.display] end, args.data)

	vim.ui.select(show, { prompt = prompt },
	function(choice)
		args.on_select( utils.filter(function(tbl)
			return tbl[args.display] == choice
		end,args.data ))
	end)

end

return M
