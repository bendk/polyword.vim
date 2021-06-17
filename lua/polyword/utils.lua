local M = {}

local esc = vim.fn.nr2char(27)

function M.get_options(opts, defaults)
    if opts == nil then
	return defaults 
    else
	return vim.tbl_extend('keep', opts, defaults)
    end
end

function M.visual_select(startline, startcol, endline, endcol)
    -- Leave visual mode if it's currently selected
    vim.cmd('normal! ' .. esc)
    vim.fn.setpos('.', {0, startline, startcol, 0})
    vim.cmd("normal! v")
    vim.fn.setpos('.', {0, endline, endcol, 0})
end

function M.visual_select_with_command(command)
    -- Leave visual mode if it's currently selected, then go back to visual
    -- mode and run the command
    vim.cmd('normal! ' .. esc .. 'v' .. command)
end

-- Which commands are motions?
local motions = {
    w = true,
    b = true,
    e = true,
    ge = true,
}
function M.command_is_motion(command)
    return motions[command] ~= nil
end

-- Which commands are text objects?
local text_objects = {
    iw = true,
    aw = true,
}
function M.command_is_text_object(command)
    return text_objects[command] ~= nil
end

return M
