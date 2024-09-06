
-- local pickers = require('imposter.pickers.telescope_pickers')
local success,pickers = pcall(require,'imposter.pickers.telescope_pickers')
if not success then
	vim.notify('Warning: telescope not detected, defaulting to fallback pickers' )
	pickers = require('imposter.pickers.fallback')
end


local M = {}
M.selectBox = function(args)
	pickers.show_dropdown(args)
end

return M
