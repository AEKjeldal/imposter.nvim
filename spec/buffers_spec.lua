

local buffers		= require("imposter.buffers")
local constants     = require("imposter.constants")
local event_handler = require("imposter.event_handler")

local    util = require("imposter.util")

describe("kill Buffer",function()

	before_each(function()
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.buffers'] = nil
		package.loaded['imposter.event_handler'] = nil
		package.loaded['imposter.util'] = nil

		-- Reload to prevent test cross contamonation
		buffers		  = require("imposter.buffers")
        constants	  = require("imposter.constants")
        event_handler = require("imposter.event_handler")
		util		  = require("imposter.util")

	end)

	it("Removes Buffer when it exists",function()
		-- setup we want to have a active buffer named "testBuffer"
		local bufName = "testBuffer"
		buffers.create_buffer(bufName)
		local bufNo = constants.buffers[bufName]

		--delete
		buffers.kill_buffer(bufName)

		assert.is.same(nil,constants.buffers[bufName])

		
	end)

	it("does nothing when buffer does not exists",function()
		local bufName = "BufNoExist"
		--delete
		buffers.kill_buffer(bufName)
	end)
end)

describe("create Buffer",function()
	local calls = 0
	local args = {}

	before_each(function()
		calls = 0
		args  = {}
		
	
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.buffers'] = nil
		package.loaded['imposter.event_handler'] = nil
		package.loaded['imposter.util'] = nil

		-- Reload to prevent test cross contamonation
		buffers		  = require("imposter.buffers")
        constants	  = require("imposter.constants")
        event_handler = require("imposter.event_handler")
		util		  = require("imposter.util")

	end)

	it ("adds a named buffer",function()

		local bufName = "testBuffer"
		buffers.create_buffer(bufName)
		assert.is_not.same(nil,constants.buffers[bufName])
	end)

	it ("creates a valid buffer",function()

		local bufName = "testBuffer"
		buffers.create_buffer(bufName)
		assert(vim.api.nvim_buf_is_valid(constants.buffers[bufName]))
	end)

	it("emits a buffer event when replacing buffer",function()

		local bufName = "testBuffer"

		local event_spy = function(a) 
			table.insert(args,a)
			calls = calls+1
		end

		event_handler.subscribe_buffer_event("buffer_replaced",event_spy)

		buffers.create_buffer(bufName)
		buffers.create_buffer(bufName)

		assert.is.same(1,calls)
		assert.is.same(args[1],{bufName = bufName})
	end)


end)


