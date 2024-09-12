# imposter.Nvim

Enables you to cosplay as a VsCode user within the comfort of the terminal. 
This plugin is designed to help those of us stuck working with VsCode Configuration files by pretending to fit in. 
The plugin enables you to load builds, launch and test configs and integrate them into your favorite editor. 

# Gettings Started



### Importing a Workspace

To import a workspace, use the following:
```lua
local imposter = require('imposter')
imposter.import_workspace() 
```
This command will search upwards from the current working directory (cwd) and prompt the user to select a workspace.

### Running Tests and Builds
Once a workspace is imported, you can run tests and builds with the following commands:
```lua
imposter.build()
imposter.test()
```

## installation 


Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'AEKjeldal/imposter.nvim',
  requires = { {'nvim-lua/plenary.nvim', 
                'Joakker/lua-json5', run = './install.sh'}} -- for windows: ./install.ps1
}
```

## Dependencies
 Required Dependencies: 

  - [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
  - [Joakker/lua-json5](https://github.com/Joakker/lua-json5) (Notice requires cargo!)

 Optional dependencies: 
   
 - [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) For prettier menus








