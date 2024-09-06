
local constants = require("imposter.constants")
local event_handler = require("imposter.event_handler")

local M = {}

M.get_buffer = function(bufName,replace)
	replace = replace or true
	local bufNo = constants.buffers[bufName]

	if replace then
		return M.create_buffer(bufName)
	elseif bufNo and vim.api.nvim_buf_is_valid(bufNo) then
		return bufNo
	else
		return M.create_buffer(bufName)
	end

end

M.create_buffer = function(bufName)

	local old_buffer = constants.buffers[bufName]
	local new_buf = vim.api.nvim_create_buf(false,true)

	constants.buffers[bufName] = new_buf

	if old_buffer then
		event_handler.emit_buffer_event(event_handler.bufferEvents.BufferReplaced,
										{bufName=bufName})
	end

	if old_buffer and vim.api.nvim_buf_is_valid(old_buffer)  then
		-- kill old buffer
		vim.api.nvim_buf_delete(old_buffer,{ force= true})
	end

	return new_buf

end

return M
