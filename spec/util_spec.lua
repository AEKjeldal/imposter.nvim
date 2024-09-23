
local util = require('imposter.util')
local constants = require('imposter.constants')


describe("split_str splits using seperator",function()
	it("Splits path like objects",function()
		local input = '/some/path/file.txt'
		local exp = {'some','path','file.txt'}
		assert.are.same(exp,util.split_str(input,'/'))
	end)
end)



describe("format_config",function()
	before_each(function()
		-- Reload to prevent test cross contamonation
		package.loaded['imposter.constants'] = nil
		package.loaded['imposter.util'] = nil
		util		= require("imposter.util")
        constants	= require("imposter.constants")
	end)
	it("formats ${workspaceFolder} as dir",function()

		local exp   = {test_dir = '/testDir123/test' }
		constants.workspaceFolder = 'testDir123/test'
		local data = util.format_config({test_dir = "${workspaceFolder}"})
		assert.same(exp,data)
	end)

	it("formats ${workspaceFolderBase} as constants.workspaceFolderBasename",function()

		local exp   = { test_dir = '/testDir123' }
		constants.workspaceFolderBasename = 'testDir123'

		local data = util.format_config({test_dir = "${workspaceFolderBasename}"})
		-- working as intended
		assert.same(exp,data)
	end)


	it("formats ${file} as open file",function()

		local exp   = { test_file = vim.fn.expand('%') }
		local data = util.format_config({test_file = "${file}"})
		-- working as intended
		assert.same(data,exp)
	end)


end)

describe("copy",function()
	it("copies the table",function()
		local exp = {test =1, test2='test'}
		local result = util.copy(exp)
		assert.same(exp,result)
	end)
	it("handles tables",function()
		local exp = {test =1, test2='test', table={test3=123}}
		local result = util.copy(exp)
		assert.same(exp,result)
	end)

	it("returns a new table",function()
		local exp = {test =1, test2='test'}
		local result = util.copy(exp)
		assert.not_equal(exp,result)
	end)

	it("also copies deep tables",function()
		local exp = {test =1, test2='test', table={test3=123}}
		local result = util.copy(exp)
		assert.not_equal(exp.table,result.table)
	end)

end)



describe("filter filters table",function()

	it("Takes emptyTable",function()
		local condition = function(input) end
		local emptyTable = {}

		local exp = {}
		assert.are.same(exp,util.filter(condition,emptyTable))
	end)

	it("matches with filter",function()
		local filter = function(x) return x == "PickThis" end

		local inputTable = {"test", "PickThis", 'another_elem', 123  }

		local exp = {"PickThis"}
		assert.are.same(exp,util.filter(filter,inputTable))
	end)


	it("Matches objects",function()

		local filter = function(x) return x.text == "PickThis" end

		local inputTable = {{text="test"}, {text="PickThis"}, {text='another_elem'}, {text=123}}

		local exp = {{text="PickThis"}}

		assert.are.same(exp,util.filter(filter,inputTable))

	end)

	it("Matches objects of different types",function()

		local filter = function(x) return x.text == "PickThis" end
		--number would fail thil due to filter function
		local inputTable = {{notHere="test"},{text="test"}, {text="PickThis"}, 'another_elem'} 

		local exp = {{text="PickThis"}}

		assert.are.same(exp,util.filter(filter,inputTable))

	end)
end)

