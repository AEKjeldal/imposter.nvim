local imposter = require('imposter.importer')
local constants = require('imposter.constants')


local test_file = 'spec/test_data/sample_workspace.code-workspace'


describe("Imports code-workspace folders",function()

	before_each(function()
		-- teardown
		package.loaded['imposter.importer'] = nil --unload
		package.loaded['imposter.constants'] = nil --unload
		imposter = require('imposter.importer')
		constants = require('imposter.constants')
	end)

	it('sets workspaceFolder',function()
		imposter.import_workspace(test_file)

		local exp = 'spec/test_data/'
		assert.is_equal(exp,constants.workspaceFolder)
	end)

	it('sets workspaceFolderBasename',function()
		imposter.import_workspace(test_file)

		local exp = 'test_data'
		assert.is_equal(exp,constants.workspaceFolderBasename)
	end)

	it('imports folders with defined name',function()
		imposter.import_workspace(test_file)
		local exp = '/path/to/firstType'
		assert.is_equal(exp,constants.folders['type1'])
	end)

	it('imports folders without a defined name',function()
		imposter.import_workspace(test_file)

		local exp = '/path/to/type2'
		assert.is_equal(exp,constants.folders['type2'])
	end)

	it('imports pats as an itable',function()
		imposter.import_workspace(test_file)

		local exp = '/path/to/firstType'
		assert.is_equal(exp,constants.paths[1])
		local exp = '/path/to/type2'
		assert.is_equal(exp,constants.paths[2])
	end)


end)

describe("Imports code-workspace tasks",function()

	before_each(function()
		-- teardown
		package.loaded['imposter.importer'] = nil --unload
		package.loaded['imposter.constants'] = nil --unload
		imposter = require('imposter.importer')
		constants = require('imposter.constants')
	end)

	it ('imports and stores launch configurations',function()
		imposter.import_workspace(test_file)

		local expected_configuration = {
        {
            label= 'build project1',
            type= 'shell',
            command= 'g++',
            args= {
                '-g',
                'src/*.cpp',
                '-o',
                'build/${workspaceFolderBasename}'
            },
            group= {
                kind= 'build',
                isDefault= true
            },
            problemMatcher= {'$gcc'},
            presentation= {
                echo= true,
                reveal= 'always',
                focus= false,
                panel= 'shared'
            },
            options= {
                cwd= '${workspaceFolder}/project1'
            }
        },
        {
            label= 'build project2',
            type= 'shell',
            command= 'g++',
            args= {
                '-g',
                'src/*.cpp',
                '-o',
                'build/${workspaceFolderBasename}'
            },
            group= {
                kind= 'build',
                isDefault= true
            },
            problemMatcher= {'$gcc'},
            presentation= {
                echo= true,
                reveal= 'always',
                focus= false,
                panel= 'shared'
            },
            options= {
                cwd= '${workspaceFolder}/project2'
            }
        }}

		assert.are.same(expected_configuration,constants.tasks)
	end)
end)
