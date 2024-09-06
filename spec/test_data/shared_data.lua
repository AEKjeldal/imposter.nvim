local M = {}

M.dependend_tasks = {
	{
		label = "build",
		type = "shell",
		command = "echo Building the project...",
		group = {
			kind = "build",
			isDefault = true
		},
		problemMatcher = {}
	},
	{
		label = "lint",
		type = "shell",
		command = "echo Linting the code...",
		group = "test",
		problemMatcher = {}
	},
	{
		label = "test",
		type = "shell",
		command = "echo Running tests...",
		group = "test",
		problemMatcher = {}
	},
	{
		label = "build-and-test",
		type = "shell",
		command = "echo Running build, lint, and tests...",
		dependsOn = { "build", "lint", "test" },
		group = "test",
		problemMatcher = {}
	}
}



M.sample_task =  {
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
                cwd= '${workspaceFolder:HEJSAN}/project1'
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
            group="build",
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
		},
		{

			label= "Run Unit Tests",
			type= "shell",
			command= "npm run test:unit",
			group={
				kind= "test",
				isDefault= true
			}
		},
		{

			label= "Run Integration Tests",
			type= "shell",
			command= "npm run test:int",
			group='test'
		},

	}


return M
