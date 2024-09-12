

local buffers		= require("imposter.buffers")
local constants     = require("imposter.constants")
local event_handler = require("imposter.event_handler")

local    util = require("imposter.util")

describe("Create Buffer",function()

	before_each(function()
		-- Reload to prevent test cross contamonation
		buffers		  = require("imposter.buffers")
        constants	  = require("imposter.constants")
        event_handler = require("imposter.event_handler")
		util = require("imposter.util")
	end)

	after_each(function()
		-- clear to prevent tests cross contamination

		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.buffers'] = nil
		package.loaded['imposter.event_handler'] = nil
		package.loaded['imposter.util'] = nil
	end)


	it ("adds a named buffer",function()

		local bufName = "testBuffer"
		local exp = 2 -- the expected amount of buffers
		buffers.create_buffer(bufName)

		assert.equals(exp,constants.buffers[bufName])
	end)

	it("Emits Event: buffer_replaced if replacing_buffer",function()

		local bufName = "testBuffer"
		local event_spy = spy.new(function() end)
		event_handler.subscribe_buffer_event("buffer_replaced",event_spy)

		buffers.create_buffer(bufName)
		buffers.create_buffer(bufName)

		assert.spy(event_spy).was_called()
		assert.is.same(event_spy.calls[1].vals[1],{bufName = bufName})
	end)

	it ("Creates unlisted scratch buffer",function()
		local bufName = "testBuffer"
		local exp = 34

		local api = mock(vim.api, true)

		api.nvim_create_buf.returns(exp)

		buffers.create_buffer(bufName)

		assert.stub(api.nvim_create_buf).was_called_with(false, true)
		mock.revert(api)
		assert.equals(exp, constants.buffers[bufName])
	end)


	it ("returns the new buffer",function()
		local bufName = "testBuffer"
		local exp = 34

		local api = mock(vim.api, true)

		api.nvim_create_buf.returns(exp)

		local result = buffers.create_buffer(bufName)

		mock.revert(api)
		assert.equals(exp, result)

	end)

	it ("forcefully deletes the Old buffer",function()
		local bufName = "testBuffer"
		local exp = vim.api.nvim_create_buf(false,true)
		constants.buffers[bufName] = exp

		local del_spy = spy.on(vim.api,"nvim_buf_delete")

		buffers.create_buffer(bufName)

		assert.spy(del_spy).was_called_with(exp,{force=true})
		del_spy:revert()

	end)

	it ("skips forcefully deleting if the old buffer does not exist",function()
		local bufName = "testBuffer"
		local exp = 1337
		constants.buffers[bufName] = exp

		local del_spy = spy.on(vim.api,"nvim_buf_delete")

		buffers.create_buffer(bufName)

		assert.spy(del_spy).was_not_called_with(exp,{force=true})
		del_spy:revert()
	end)

end)

