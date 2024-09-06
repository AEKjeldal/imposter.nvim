local M = {}

M.root_indicators = {'.git','.gitignore'}
M.buffers = {}

M.tasks = {}

M.workspaceFolder = ""
M.workspaceFolderBasename = ""

M.lunch_config = {} -- table containing specific launch configs 

M.folders = {}  -- accessed as a key value pair ie: name -> path
M.paths =  {}   -- folder containing all paths 
return M
