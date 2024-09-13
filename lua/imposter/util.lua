local json5 = require('json5')
local constants = require('imposter.constants')

local function load_file(filename)
	local file = io.input(filename)
	return file:read("*a")
end


local M = {}

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
		table[key] = default_val()
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

-- Taken from https://code.visualstudio.com/docs/editor/variables-reference
-- local replacements = {workspaceFolder =  vim.fn.getcwd,
-- 					  file = function() vim.fn.expand('%') end,
-- 					  workspaceFolderBasename = function()
-- 												 local p_split = M.split_path(vim.fn.getcwd())
-- 												 return p_split[#p_split]
-- 												end   }

local replacements = {workspaceFolder =  function() return M.root()..constants.workspaceFolder end,
					  file = function() vim.fn.expand('%') end,
					  workspaceFolderBasename =  function() return M.root()..constants.workspaceFolderBasename end
										   }




local function format_str(input_str)
	local m = string.match(input_str,'${workspaceFolder:([%w_%d]+)}')
	--
	if m then
		-- TODO: This should look up the stored variable in constants!
		-- TODO: make compatible with windows!
		local path = constants.folders[m] or m
		input_str = string.gsub(input_str,":"..m..'}',"}"..path)
	end


	-- TODO Expand this to all variable referenes
	-- TODO This does not properly find variable references in the middle of strings
	local re = vim.regex("\\${\\(workspaceFolder\\|workspaceFolderBasename\\|file\\)}")
	local st,en = re:match_str(input_str)
	if st then
		local match = string.sub(input_str,st+3,en-1)
		local replacement = replacements[match]() or  ''
		input_str = string.gsub(input_str,'${'..match..'}',replacement)
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
	result = {}
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


return M
