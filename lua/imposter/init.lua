local M = {}

local importer  = require('imposter.importer')
local workspace = require('imposter.workspace')
local tasks     = require('imposter.tasks')
local ui	    = require('imposter.ui')
local constants = require('imposter.ui')

M.setup = function(opts)
	opts.constants = constants.set_defaults(opts)
end
M.import_workspace = importer.import_workspace

M.run_task    = tasks.run_task
M.toggle_view = ui.toggleView
M.show        = ui.show_output_window

M.toggle_term = function() ui.toggleView() end

M.import_workspace = function(dir)
	workspace.LoadWorkspace(dir)
end

M.test = function(opts)
	opts = opts or {}
	tasks.run_test()
end

M.build = function(opts)
	opts = opts or {}
	tasks.run_build(opts)
end

M.constants = require('imposter.constants')
return M
