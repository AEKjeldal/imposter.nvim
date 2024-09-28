local util = require('imposter.util')
local constants = require('imposter.constants')


local M = {}

local function set_workspaceFolder(path)

	local path_split = util.split_str(path,util.sep())

	constants.workspaceFolder = vim.fn.fnamemodify(path,':p:h')
	constants.workspaceFolderBasename = vim.fn.fnamemodify(path,':p:h:t')

end

local function import_folders(paths)
	constants.folders = {}
	constants.paths = {}

	if paths then
		for _,elem in pairs(paths) do
			local path = elem.path
			local name = elem.name

			if not name then
				local splpath = util.split_str(path,'/')
				name = splpath[#splpath]
			end
			table.insert(constants.paths,path)
			constants.folders[name] = path
		end
	end
end

local function import_launch_config(launch)
	constants.launch_config = launch.configurations
	-- constants.launch_config = util.format_config(launch.configurations)
end

local function import_tasks(tasks)
	constants.tasks = tasks
	-- constants.tasks = util.format_config(tasks)
end


M.import_workspace = function(path)
	set_workspaceFolder(path)

	local workspace = util.json_parse(path)

	import_folders(workspace.folders)
	import_launch_config(workspace.launch)
	import_tasks(workspace.tasks)
end

return M
