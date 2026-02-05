
local util      = require('imposter.util')
local constants = require('imposter.constants')
local event_handler = require("imposter.event_handler")

local venv_default_location = (os.getenv('HOME') or os.getenv('USERPROFILE'))..'/.virtualenvs'

local function venv_exec()
    if os.getenv('OS') == 'Windows_NT' then
        return '/Scripts/python.exe'
    else
        return '/bin/python'
    end
end


local get_python_venvs = function(path)
    local root = util.git_get_top_level(path):gsub("\n[^\n]*$", "")

    local venvs = {}
    local paths = {venv_default_location,root}


    for _,p in pairs(paths) do
        local matches = vim.fs.find('pyvenv.cfg',{path=p})
        for _,match in pairs(matches) do
            table.insert(venvs,vim.fn.fnamemodify(match,':p:h'))
        end
    end
    return venvs
end



local M  = {}


M.select_venv = function(path)
    local venvs = get_python_venvs(path)
    local t  = {}
    for _,venv in pairs(venvs) do
        table.insert(t,{path=venv})
    end

	local data = { on_select = function(venv) M.venv_exec_path = venv[1].path .. venv_exec() 
    end,
        data = t,display='path' }
	event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox ,data)
end

return M


