
local    util = require("imposter.util")
local buffer_event_subscribers = util.setDefault({},function() return {} end)

local M = {}
M.bufferEvents = {
	RequestBuffer  = "request_buffer",
	BufferReplaced = "buffer_replaced",
	BufferShow     = "buffer_show",
	SelectBox	   = "select_box"
}

M.emit_buffer_event = function(event,data)
  for _,callback in pairs(buffer_event_subscribers[event]) do
	  callback(data)
  end
end

M.subscribe_buffer_event = function(event,callback)
	table.insert(buffer_event_subscribers[event],callback)
end

return M
