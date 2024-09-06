
local ui        = require("imposter.ui")
local constants = require("imposter.constants")
local event_handler = require("imposter.event_handler")



describe("ui",function()
	before_each(function()
		-- Reload to prevent test cross contamonation
		ui		  = require("imposter.ui")
        constants = require("imposter.constants")
        event_handler = require("imposter.event_handler")
	end)

	after_each(function()
		-- clear to prevent tests cross contamination
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.ui'] = nil
		package.loaded['imposter.event_handler'] = nil
	end)


	describe('ToggleWindow',function()


		it("requests a termbuffer if none", function()
			-- fill in test 
			local event_spy = spy.new(function() end)
			local exp = {bufferType  = 'terminal'}
			event_handler.subscribe_buffer_event("request_buffer",event_spy)

			ui.toggleView()
			-- Test if term buffer is requestef
			assert.spy(event_spy).was_called()

			assert.same(exp, event_spy.calls[1].vals[1])
		end)



		it("hides a window if shown", function()
			-- fill in test 
			constants.active_buffer = "test"
			local bufferNo  = vim.api.nvim_create_buf(false,true)
			constants.buffers = { test = bufferNo }

			vim.cmd("split")
			ui.outputWindow = vim.api.nvim_get_current_win()

			ui.toggleView()
			-- Test if output window is valid
			assert(not vim.api.nvim_win_is_valid(ui.outputWindow))
		end)



	end)


describe("hide_buffer",function()

	it('Hides Windows if shown',function()

		vim.cmd("split")

		local exp		= vim.api.nvim_get_current_win()
		ui.outputWindow = exp

		local win_close_spy = spy.on(vim.api,"nvim_win_close")

		ui.hide_buffer()
		assert.spy(win_close_spy).was_called_with(exp,{force=true})

	end)

end)



describe("show_buffer",function()


	-- before_each(function()
	-- 	-- Reload to prevent test cross contamonation
	-- 	ui		  = require("imposter.ui")
	--         constants = require("imposter.constants")
	-- end)
	--
	-- after_each(function()
	-- 	-- clear to prevent tests cross contamination
	--
	-- 	package.loaded['imposter.constants'] = nil
	-- 	package.loaded['imposter.ui'] = nil
	-- end)



	it('sets buffer as active if buffer Exists',function()
		-- we want an existing buffer
		local bufferType = "BufferType"
		--
		-- Put create a buffer and put it in constant.buffers
		local bufferNo  = vim.api.nvim_create_buf(false,true)
		constants.buffers[bufferType] = bufferNo



		ui.show_buffer(bufferType)
		assert(bufferType,constants.active_buffer)
	end)

	it("puts buffer in window if buffer exists",function()
		-- we want an existing buffer
		local bufferType = "BufferType"
		local winNo = vim.api.nvim_get_current_win()
		ui.outputWindow = winNo
		--
		-- Put create a buffer and put it in constant.buffers
		local bufferNo  = vim.api.nvim_create_buf(false,true)
		local exp = bufferNo

		constants.buffers[bufferType] = bufferNo

		local set_buf_mock = spy.on(vim.api,"nvim_win_set_buf")

		ui.show_buffer(bufferType)

		assert.spy(set_buf_mock).was_called_with(winNo,exp)

		set_buf_mock:revert()

	end)


	it('warns user and does nothing if buffer does not Exists',function()
		-- we want an existing buffer
		local bufferType = "BufferType"
		local bufferNo  = 123
		constants.buffers[bufferType] = bufferNo

		local api = mock(vim.api.nvim_buf_is_valid, true)
		api.returns(false)

		ui.show_buffer(bufferType)
		mock.revert(api)

		assert.is_not_equal(bufferType,constants.active_buffer)

		-- local api = mock(vim.api, true)
		-- local win_spy = spy.on(vim.api,"nvim_buf_delete")
		-- assert.spy(win_spy).was_not_called_with(bufferNo,winNo)
	end)

end)
end)
