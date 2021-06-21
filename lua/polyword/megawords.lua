local re = require('polyword.re')
local utils = require('polyword.utils')
local vim = require('polyword.vim')

local M = {}

function M.megaword(command)
    local old_iskeyword = vim.opt_get('iskeyword')
    vim.opt_append('iskeyword', '.')
    vim.opt_append('iskeyword', ':')

    if utils.command_is_motion(command) then
	vim.cmd('normal! ' .. command)
    elseif utils.command_is_text_object(command) then
	utils.visual_select_with_command(command)
    end
    vim.opt_set('iskeyword', old_iskeyword)
end

return M
