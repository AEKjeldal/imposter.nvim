
local util      = require('imposter.util')
local event_handler = require("imposter.event_handler")

local venv_default_location = (os.getenv('HOME') or os.getenv('USERPROFILE'))..'/.virtualenvs'


local function venv_exec_path()
    if os.getenv('OS') == 'Windows_NT' then
        return '/Scripts'
    else
        return '/bin'
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


local function set_venv(venv_path)
    vim.fn.setenv('VIRTUAL_ENV',venv_path)
    local path_orig = vim.fn.getenv('PATH')

    vim.fn.setenv('PATH', venv_path ..venv_exec_path() ..util.path_sep()..path_orig)
    vim.notify(venv_path)
    -- Create mechanissm to update every running browser 
end


local M  = {}


M.select_venv = function(opts)
    opts = opts or {}
    local venvs = get_python_venvs(opts.path)
    local t  = {}
    for _,venv in pairs(venvs) do
        table.insert(t,{path=venv})
    end

	local data = { on_select = function(venv_path)

        if venv_path[1] == nil then
            return
        end

        set_venv(venv_path[1]['path'])
        if type(opts.callback) == 'function' then
            opts.callback()
        end
    end,
        data = t,display='path' }
	    event_handler.emit_buffer_event(event_handler.bufferEvents.SelectBox ,data)
end


M.setup = function(opts)
    -- setup_pytest()
    local pytest_provider =  require('imposter.builtins.python_pytest')
    local opts = {}
    M.select_venv({callback= function() pytest_provider.select_test_dir() end})
    pytest_provider.setup(opts)
end


-- Setup Commands
vim.api.nvim_create_user_command('ImposterPythonSelectVenv',function() M.select_venv() end,{})
vim.api.nvim_create_user_command('ImposterPythonSelectTestdir',function() M.select_test_dir() end,{})

return M


