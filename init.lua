require('config.nvim')

require('utils.globals')

require('config.options')
require('config.filetypes')
require('config.lazy')
require('config.keymappings')
require('config.autocmds')

require('internal.cursorword')
require('internal.statusline').setup()
