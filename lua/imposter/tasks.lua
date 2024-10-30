local util = require('imposter.util')
local constants = require('imposter.constants')
local buffers = require('imposter.buffers')
local event_handler = require('imposter.event_handler')

local last_run = {}


local function test_filter(task)
	return (task.group == "test" or task.group.kind=="test")
end

local function build_filter(task)
	return (task.group == "build" or task.group.kind=="build")
end


local M = {}

local function get_task_type(task)
	if type(task.group) == 'table' then
		return task.group.kind
	end

	return task.group
end


local function open_terminal()
	local output_buffer = buffers.get_buffer('terminal')

	vim.api.nvim_buf_call(output_buffer,function ()
		vim.cmd.terminal()
		-- We want escape to escape?
		vim.keymap.set("t", "<esc>", "<C-\\><C-n>")
	end)
end


local function format_task (task)

	local os_settings = task[util.os()] or {}

	task = util.format_config(task)

	util.update(task,os_settings)


	local task_type = get_task_type(task)
	local options = task.options or {}
	-- this fails of options is empty
	local workspaceFolder = options.cwd or vim.fn.getcwd()
	local command = { task.command }

	for _,arg in pairs(task.args or {}) do
		table.insert(command,arg)
	end

	local opts = {
		cwd = workspaceFolder,

		on_stdout = function(job_id, data)
			vim.api.nvim_buf_call(constants.buffers[task_type], function() vim.cmd.normal("G") end)
		end,
		on_stderr = function(job_id, data)
			-- Print stderr to the terminal buffer in red
			vim.api.nvim_buf_call(constants.buffers[task_type], function() vim.cmd.normal("G") end)
		end

	}

	return command, opts
end

local function run_in_term(command,opts)
	-- if we only have one argument run it in shell
	-- see :h jobstart
	if #command == 1 then
		command = command[1]
	end

	return function() vim.fn.termopen(command,opts) end
end


--todo: this should be in utils

local function compose_task_queue(taskName,queue)
	queue = queue or {}
	table.insert(queue,1,taskName)


	local task = M.get_task(taskName)[1]
	if not task then
		vim.notify('Could Not find any task with label: '..taskName)
		return nil
	end

	for _,task_name in pairs(task.dependsOn or {}) do
		compose_task_queue(task_name,queue)
	end

	return queue
end

local function empty_task_queue(queue)
	if not (next(queue) == nil) then

		local taskLabel = util.pop(queue)

		local task = M.get_task(taskLabel)[1]

		local bufType = get_task_type(task)
		local bufNo   = buffers.create_buffer(bufType)

		local command, opts = format_task(task)

		opts.on_exit = function(_,retVal,_)
			if retVal ~= 0 then
				vim.notify('Task: '..taskLabel..' Failed With ExitCode: '..vim.inspect(retVal))
			else
				local resp, result = pcall(function() empty_task_queue(queue) end)
				if not resp then
					vim.notify('Running New Task Failed! \nDebug Info: '..
						vim.inspect(result)..
						"\n"..vim.inspect(resp)..
						"\nCommand: "..vim.inspect(command)..
						"\nArgs: "..vim.inspect(opts))
				end
			end
		end


		local t = { type=get_task_type(task) ,
		            presentation = task.presentation }

		if t.presentation then
 			event_handler.emit_buffer_event(event_handler.bufferEvents.BufferShow,t)
		end

		local handle = vim.api.nvim_buf_call(bufNo , run_in_term(command,opts))
		return handle

	end
end


M.run_task = function(taskLabel)
	local task_queue = compose_task_queue(taskLabel)

	if task_queue then
		empty_task_queue(task_queue)
	end
end

M.get_task = function(task_label)
	local filter = function(x)
		return x.label == task_label
	end

	local tasks = util.copy(constants.builtin_tasks)
	util.update(tasks,constants.tasks)
	return util.filter(filter,tasks)

end

M.get_tests = function(test_label)
	local filter = function(x)
		local is_test = (x.group == "test" or x.group.kind=="test")
		return is_test and x.label == test_label
	end

	return util.filter(filter,constants.tasks)
end

M.get_builds = function(build_label)

	local tasks = util.copy(constants.builtin_tasks)
	util.update(tasks,constants.tasks)

	local filter = function(x)
		local is_test = (x.group == "build" or x.group.kind=="build")
		return (is_test and x.label == build_label)
	end

	return util.filter(filter,tasks)
end

M.run_test = function(opts)
	opts=opts or {}

	if (opts.rerun and last_run.test) then
		opts.test_label = opts.test_label or last_run.test
	end

	if opts.test_label then
		return M.run_task(opts.test_label)
	end

	-- This should be handled elsewhere!
	local tasks = util.copy(constants.builtin_tasks)
	util.update(tasks,constants.tasks)

	local content = {on_select = function(tbl)
									local label = tbl[1].label
									last_run.test = label
									M.run_task(label)
								 end,
					 data = util.filter(test_filter, tasks) or {},
					 display = 'label' }

	event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox,content)
end


M.run_build = function(opts)

	if (opts.rerun and last_run.build) then
		opts.build_label = opts.build_label or last_run.build
	end

	if opts.build_label then
		return M.run_task(opts.build_label)
	end

	-- This should be handled elsewhere!
	local tasks = util.copy(constants.builtin_tasks)
	util.update(tasks,constants.tasks)

	local content = {on_select = function(tbl)
									local task_label = tbl[1].label
									last_run.build = task_label
									M.run_task(task_label)
								end,
					 data = util.filter(build_filter, tasks) or {},
					 display = 'label' }

	event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox,content)
end

event_handler.subscribe_buffer_event(event_handler.bufferEvents.RequestBuffer,
		function(request)
			if request.bufferType == 'terminal' then
				open_terminal()
			end
		end)

return M

