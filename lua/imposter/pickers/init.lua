pickers = require('imposter.pickers.fallback')

local M = {}
M.selectBox = function(args)
	pickers.show_dropdown(args)
end

return M
