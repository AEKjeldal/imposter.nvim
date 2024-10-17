local json5 = require('json5')
local constants = require('imposter.constants')

local function load_file(filename)
	local file = io.input(filename)
	return file:read("*a")
end





-- Taken from https://code.visualstudio.com/docs/editor/variables-reference
local replacements = {workspaceFolder =  function() return constants.workspaceFolder end,
					  file = function() return vim.fn.expand('%') end,
					  fileBasename = function() return vim.fn.expand('%:p:t') end,
					  fileExtname = function() return '.'..vim.fn.expand('%:e') end,
					  fileDirname = function() return vim.fn.expand('%:p:h') end,
					  fileBasenameNoExtension = function() return vim.fn.expand('%:t:r') end,
					  pathSeperator = function() return M.sep() end,
					  userHome = function() return vim.fn.expand('~/') end,
					  ['/'] = function() return M.sep() end,
					  cwd = function() return vim.fn.getcwd end,
					  workspaceFolderBasename =  function() return constants.workspaceFolderBasename end
										   }

local M = {}

M.set_defaults = function(opts)
	M.update(constants.root_indicators,opts.root_indicators or {})
	M.update(constants.builtin_tasks,opts.tasks or {})
	M.update(constants.builtin_launch_configs,opts.launch_configs or {})
end


M.update =function(table,replacements)
	for k,v in pairs(replacements) do
		table[k] = v
	end
end


M.os = function()
	local sysname = vim.loop.os_uname().sysname

	if sysname == 'Linux' then
		return 'linux'
	elseif sysname == osx then
		return 'osx'
	elseif 'Windows_NT' then
		return 'windows'
	end

	error('Unsupported os: '..sysname)
end


M.pop =function(tbl,pos)
	pos = pos or 1

	local data = tbl[pos]
	table.remove(tbl,pos)
	return data

end

M.copy = function(table)
	local result = {}
	for k,v in pairs(table) do
		if type(v) == 'table' then
			result[k] =  M.copy(v)
		else
			result[k] = v
		end
	end
	return result
end


M.setDefault = function(tbl,default_val)
	local mt = {__index = function(table,key)
		table[key] = default_val(key)
		return table[key] end}
	setmetatable(tbl,mt)
	return tbl
end

M.map = function(map,tbl)
	local result = {}

	for _,data in pairs(tbl) do
		table.insert(result,map(data))
	end
	return result
end

M.filter = function(filter,input)
	local result = {}
	for _,x in ipairs(input) do
		if filter(x) then
			table.insert(result, x)
		end
	end
	return result
end

M.root = function()
	if os.getenv('OS') == 'Windows_NT' then
		-- Temp workaround for now
		return ''
	else
		return '/'
	end
end

local function format_str(input_str)
	-- local re = vim.regex("\\${\\(workspaceFolder\\|workspaceFolderBasename\\|file\\|userHome\\)\\(:\\w\\+\\)*}")
	local re = vim.regex("\\${\\(\\w\\+\\)\\(:\\w\\+\\)*}")
	local st,en = re:match_str(input_str)

	if st then
		local match = string.sub(input_str,st+3,en-1)
		local parts = M.split_str(match,':')
		local replacement = replacements[parts[1]]()

		if #parts > 1 then
			replacement = replacement..'/'..(constants.folders[parts[2]] or  '')
		end
		input_str = string.gsub(input_str, string.sub(input_str,st,en) ,replacement)
	end


	return input_str
end

M.format_config = function(configuration)
	local result = {}
	for idx,conf in pairs(configuration) do
		if type(conf) == 'table' then
			local t = M.format_config(conf)
			conf = t
		elseif type(conf) == 'string' then
			conf = format_str(conf)
		end
		result[idx] = conf
	end
	return result
end

M.split_str = function(input,sep)
	local result = {}
	for str in string.gmatch(input,'[^'..sep..']+') do
		table.insert(result,str)
	end

	return result
end

M.sep = function()
	if os.getenv('OS') == 'Windows_NT' then
		return '\\'
	else
		return '/'
	end
end

M.split_path = function(path)
	return M.split_str(path,M.sep())
end

M.json_parse = function(filename)
	return json5.parse(load_file(filename))
end


M.setDefault(replacements,function(replacement) error('Replacement: '..vim.inspect(replacement)..' did not resolve to any replacement')  end)

return M
