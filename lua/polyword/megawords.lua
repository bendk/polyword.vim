local re = require('polyword.re')
local utils = require('polyword.utils')

local M = {}

function M.megaword(command)
    local old_iskeyword = vim.opt.iskeyword
    vim.opt.iskeyword:append('.')
    vim.opt.iskeyword:append(':')

    if utils.command_is_motion(command) then
	vim.cmd('normal! ' .. command)
    elseif utils.command_is_text_object(command) then
	utils.visual_select_with_command(command)
    end
    vim.opt.iskeyword = old_iskeyword
end

return M
