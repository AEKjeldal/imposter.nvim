
local test_data = require("spec.test_data.shared_data")
local tasks = require("imposter.tasks")
local utils = require("imposter.util")
local constants   = require("imposter.constants")
local buffers   = require("imposter.buffers")




describe("run_task",function()
	local termopen = vim.fn.termopen
	before_each(function()
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.tasks'] = nil
		package.loaded['imposter.buffers'] = nil
		package.loaded['imposter.util'] = nil

		tasks = require("imposter.tasks")
		constants = require("imposter.constants")
		buffers = require("imposter.buffers")
		utils = require("imposter.util")
	end)

	after_each(function()
		-- resets monkeypatch!
		vim.fn.termopen = termopen

		-- clear to prevent tests cross contamination
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.tasks'] = nil
		package.loaded['imposter.buffers'] = nil
		package.loaded['imposter.util'] = nil

	end)




	it("launches task if task exist",function()

		-- local event_spy = mock(vim.fn.termopen,true)
		local termopen = vim.fn.termopen
		local calls = 0
		local args = {}

		-- monkey patching as mock does not work here!
		vim.fn.termopen = function(...)
			calls = calls +1
			table.insert(args,{...})
		end

		constants.tasks = utils.format_config(test_data.sample_task)
		local taskname = 'build project2'

		-- Pcall to ensure we reset termopen
		pcall(function() tasks.run_task(taskname) end)

		vim.fn.termopen = termopen

		-- Create a spy to assert command and opts are called on vim.fn.termopen
		assert.are.same(calls,1)

	end)


	it("handles compound tasks",function()

		constants.tasks = utils.format_config(test_data.dependend_tasks)
		-- monkey patching, 
		-- preferaby find a way to do this slightly more elegant
		local termopen = vim.fn.termopen
		-- local create_buf = buffers.create_buffer

		buffers.create_buffer = function() return vim.api.nvim_create_buf(false,true) end

		local calls = 0
		local args = {}

		vim.fn.termopen = function(...)
			local _,opts = ...
			calls = calls +1
			table.insert(args,{...})
			opts.on_exit(1,0)
		end

		local taskname = 'build-and-test'

		tasks.run_task(taskname)

		vim.fn.termopen = termopen
		-- buffers.create_buffer = create_buf

		assert.equals(4,calls)
	end)

	it("Priorities Linux Specific settings",function() 

		-- monkeypatches
		local sysname  = vim.loop.os_uname
		local termopen = vim.fn.termopen
		local exp = {'echo','Linux' }

		vim.loop.os_uname = function()
			return { sysname = 'Linux' }
		end

		constants.tasks = test_data.os_task
		local taskname = 'OsTask'

		local calls = 0
		local args = {}

		vim.fn.termopen = function(...)
			local _,opts = ...
			calls = calls +1
			table.insert(args,{...})
			opts.on_exit(1,0)
		end

		tasks.run_task(taskname)



		-- put them back
		vim.fn.termopen   = termopen
		vim.loop.os_uname = sysname

		assert.are.same(exp,args[1][1])

	end)

	it("Priorities Windows Specific settings",function() 

		-- monkeypatches
		local sysname  = vim.loop.os_uname
		local termopen = vim.fn.termopen
		local exp = {'echo','Windows' }

		vim.loop.os_uname = function()
			return { sysname = 'Windows_NT' }
		end

		constants.tasks = test_data.os_task
		local taskname = 'OsTask'

		local calls = 0
		local args = {}

		vim.fn.termopen = function(...)
			local _,opts = ...
			calls = calls +1
			table.insert(args,{...})
			opts.on_exit(1,0)
		end

		tasks.run_task(taskname)



		-- put them back
		vim.fn.termopen   = termopen
		vim.loop.os_uname = sysname

		assert.are.same(exp,args[1][1])

	end)

	it("supplies cwd if a working dir is supplied", function()

		constants.workspaceFolder = vim.fn.getcwd()
		local exp  = vim.fn['getcwd']() .. "/project2"


		constants.tasks = test_data.sample_task

		-- monkey patching as mock does not work here!
		local termopen = vim.fn.termopen
		local calls = 0
		local args = {}

		vim.fn.termopen = function(...)
			calls = calls +1
			table.insert(args,{...})
		end

		local taskname = 'build project2'

		-- Pcall to ensure we reset termopen
		pcall(function() tasks.run_task(taskname) end)
		vim.fn.termopen = termopen

		-- Create a spy to assert command and opts are called on vim.fn.termopen
		assert.equals(exp,args[1][2].cwd)

	end)

	it("raises error task if task does not exist",function()
		success,_ = pcall(function() tasks.run_task('TaskNotExist') end)
		assert(not succss)
	end)

end)


describe("get_task",function()
	before_each(function()
		tasks = require("imposter.tasks")
	end)

	after_each(function()
		-- clear to prevent tests cross contamination
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.tasks'] = nil

	end)
	it("returns empty array of tasks is empty",function()
		-- ensure array is empty
		local constants = require("imposter.constants")
		constants.tasks = {}

		local task = "SomeTask"
		local exp  = {}
		assert.is.same(exp,tasks.get_task(task))
	end)

	it("returns matches",function()

		local constants = require("imposter.constants")
		constants.tasks =  test_data.sample_task

		local task = 'build project2'
		local exp  = {test_data.sample_task[2]} --corresponds to task label
		assert.is.same(exp,tasks.get_task(task))
	end)
end)


describe("get_tests",function()
	before_each(function()
		tasks = require("imposter.tasks")
	end)

	after_each(function()
		-- clear to prevent tests cross contamination
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.tasks'] = nil

	end)

	it("returns empty array of tasks is empty",function()
		-- ensure array is empty
		local constants = require("imposter.constants")
		constants.tasks = {}

		local task = "SomeTest"
		local exp  = {}
		assert.is.same(exp,tasks.get_task(task))
	end)

	it("returns matches where group is object",function()

		local constants = require("imposter.constants")
		constants.tasks =  test_data.sample_task

		local test = "Run Unit Tests"
		local exp  = {test_data.sample_task[3]} --corresponds to task label

		assert.is.same(exp,tasks.get_tests(test))

	end)
	it("returns matches where group is string",function()

		local constants = require("imposter.constants")
		constants.tasks =  test_data.sample_task

		local test = "Run Integration Tests"
		local exp  = { test_data.sample_task[4] } --corresponds to task label

		assert.is.same(exp,tasks.get_tests(test))

	end)
end)

describe("get_builds",function()
	before_each(function()
		tasks = require("imposter.tasks")
	end)

	after_each(function()
		-- clear to prevent tests cross contamination
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.tasks'] = nil

	end)

	it("returns empty array of tasks is empty",function()
		-- ensure array is empty
		local constants = require("imposter.constants")
		constants.tasks = {}

		local task = "SomeBuild"
		local exp  = {}
		assert.is.same(exp,tasks.get_task(task))
	end)

	it("returns matches where group is object",function()

		local constants = require("imposter.constants")
		constants.tasks =  test_data.sample_task

		local test = "build project1"
		local exp  = {test_data.sample_task[1]} --corresponds to task label

		assert.is.same(exp,tasks.get_builds(test))

	end)
	it("returns matches where group is string",function()

		local constants = require("imposter.constants")
		constants.tasks =  test_data.sample_task
		local test = "build project2"
		local exp  = { test_data.sample_task[2] } --corresponds to task label
		assert.is.same(exp,tasks.get_builds(test))

	end)
end)


