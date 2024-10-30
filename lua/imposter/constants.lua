local M = {}

M.root_indicators = {'.git','.gitignore'}
M.file_importers = {} -- defaults are added in importer.lua
-- M.file_importers  = {".code%-workspace","tasks.json","launch.json"}

M.buffers = {}

M.builtin_tasks = {}
M.builtin_launch_configs = {}

M.tasks = {}

M.workspaceFolder = ""
M.workspaceFolderBasename = ""

M.launch_config = {} -- table containing specific launch configs 

M.folders = {}  -- accessed as a key value pair ie: name -> path
M.paths = {}   -- folder containing all paths 

return M
