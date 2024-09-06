local plenary   = require('plenary')


local util = require("imposter.util")
local constants = require("imposter.constants")
local event_handler = require("imposter.event_handler")
local importer = require('imposter.importer')


local function find_workspaceFiles(dir)
	-- local files = plenary.scandir.scan_dir(dir..'/**/*.code-workspace', {depth=5})
	local files = plenary.scandir.scan_dir(dir, {depth=10})
	local result = {}
	for _,file in pairs(files) do 
		if string.find(file,"code%-workspace") then
			table.insert(result,file)
		end
	end
	return result
end



local function get_parent(paths)
	local result = nil
	local max_depth = 1000
	for _,path in pairs(paths) do
		local path_split = util.split_path(path)
		if #path_split < max_depth then
			result = path
			max_depth = #path_split
		end
	end
	return result
end


local function find_project_root(dir)

    dir = dir or vim.fn['getcwd']()
	local project_roots = vim.fs.find(constants.root_indicators,{
		upward=true,
		limit=5,
	    path = dir})

	local paths = {}
	for _,root in pairs(project_roots) do

		local path_split = util.split_path(root)
		local path = '/'..table.concat(path_split,util.sep(),1,#path_split-1)

		table.insert(paths,path)
	end
	return get_parent(paths)
end






local M = {}

M.find_workspaces = function(base_path)
	local result = {}

	local project_root = find_project_root(base_path)
	local workspaces = find_workspaceFiles(project_root)

	for _,workspace in pairs(workspaces) do
	  -- if not directory then is file?
	  local filename = util.split_path(workspace)
	  table.insert(result,{filename=filename[#filename], path=workspace})
	end
	return result

end


M.LoadWorkspace = function(base_path)
	local workspaces = M.find_workspaces(base_path)

	local data = { on_select = function(workspace)
		importer.import_workspace(workspace[1].path)
	end,
	data = workspaces, display='filename' }
	event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox ,data)

end



return M
