local constants		= require("imposter.constants")
local event_handler = require("imposter.event_handler")

local pickers		= require('imposter.pickers')

local M  = {}
M.outputWindow = nil


local function buffer_exist(bufferNo)

	if not (type(bufferNo) == 'number') then
		return false
	end
	return vim.api.nvim_buf_is_valid(bufferNo)

end

local output_window_visible=function()
	if not (type(M.outputWindow) == 'number') then
		return false
	end
	return vim.api.nvim_win_is_valid(M.outputWindow)
end

local function create_output_window(height, goto_window)
	height = height or 10 -- set a default in constants
	vim.cmd("bel "..height.."split")
	M.outputWindow = vim.api.nvim_get_current_win() -- we are now in termwindow
end

M.show_output_window = function(goto_window)
	if output_window_visible() then
		return
	end

	local curr_win = vim.api.nvim_get_current_win()
	create_output_window()
	if not goto_window then
		vim.api.nvim_set_current_win(curr_win)
	end
end

M.show_buffer = function(bufferType,goto_window)
	local bufferNo =  constants.buffers[bufferType]
	if buffer_exist(bufferNo) then
		constants.active_buffer = bufferType
		if not output_window_visible() then
			M.show_output_window(goto_window)
		end

		vim.api.nvim_win_set_buf(M.outputWindow,bufferNo)
	end
end

M.hide_buffer = function()
	if vim.api.nvim_win_is_valid(M.outputWindow) then
		vim.api.nvim_win_close(M.outputWindow,{force=true})
	end
end

M.toggleView = function(bufferType,goto_window)

	if output_window_visible() then
		return M.hide_buffer()
	end

	bufferType = bufferType or constants.active_buffer
	if not bufferType then
		bufferType = 'terminal'
		event_handler.emit_buffer_event(event_handler.bufferEvents.RequestBuffer,
										{bufferType=bufferType})
	end

	M.show_buffer(bufferType,goto_window)

end

M.update_buffer = function(bufferNo)
	if buffer_exist(bufferNo) and output_window_visible() then
		return vim.api.nvim_win_set_buf(M.outputWindow,bufferNo)
	end

	vim.notify("cold not set buffer!")
end


M.pick_buffer = function()

	local live_buffers  = { }

	for name,bufno in pairs(constants.buffers) do
		local data =  { name  = name,
				     	bufno	 = bufno ,
			            callback = function(data) 

							M.show_buffer(name)
						end }

		table.insert(live_buffers,data)
	end

	local create_file = {name = "Create New Buffer",
						 callback = function(data)
							 local bname = vim.fn.input("Buffer Name: ")
							vim.notify("Creating Buffer: "..bname)
							event_handler.emit_buffer_event(event_handler.bufferEvents.RequestBuffer,
															{bufferType="terminal",name=bname})
							 M.show_buffer(bname)
						 end}
	table.insert(live_buffers,create_file)

	pickers.selectBox({display = "name" ,data = live_buffers , 
					   on_select = function(data)
						   local callback = data[1].callback
						   callback(data[1])
					   end })

end


--- below here we connect the eventhandlers
event_handler.subscribe_buffer_event(event_handler.bufferEvents.BufferReplaced,function(data)
	local bufNo = constants.buffers[data.bufName]
	M.update_buffer(bufNo)
end)

event_handler.subscribe_buffer_event(event_handler.bufferEvents.BufferShow,
function(i)

	local type	       = i.type
	local presentation = i.presentation

	if presentation.reveal == 'always' then
		M.show_buffer(type)
	end
end)

event_handler.subscribe_buffer_event(event_handler.bufferEvents.SelectBox, function(data)
	if data then
		pickers.selectBox(data)
	end
end)

return M

