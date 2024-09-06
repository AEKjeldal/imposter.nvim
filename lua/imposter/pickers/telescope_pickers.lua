local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local action = require('telescope.actions')
local action_state = require('telescope.actions.state')

local utils = require('imposter.util')

local M = {}

M.show_dropdown = function(args)

	local display = args.display or function(data) return data end -- use this to select which data to present

	local show = utils.map(function(tbl) return tbl[display] end, args.data)

	pickers.new(require('telescope.themes').get_dropdown{},{
		finder= finders.new_table{
			results = show
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(bufno,_)

			action.select_default:replace(function()
				action.close(bufno)
				local selection = action_state.get_selected_entry()

				local result = utils.filter(function(tbl)

					return tbl[display] == selection[1]
				end,args.data )

				args.on_select(result)
			end)
			return true
		end,
	}):find()
end

return M
