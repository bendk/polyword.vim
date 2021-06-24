local vim = require('polyword.vim')
local M = {}

function M.get_options(opts, defaults)
    if opts == nil then
        return defaults 
    else
        for key, value in pairs(defaults) do
            if opts[key] == nil then opts[key] = value end
        end
        return opts
    end
end

function M.visual_select(startline, startcol, endline, endcol)
    -- Leave visual mode if it's currently selected
    vim.setpos('.', {0, startline, startcol, 0})
    vim.cmd("normal! v")
    vim.setpos('.', {0, endline, endcol, 0})
end

function M.visual_select_with_command(command)
    -- Leave visual mode if it's currently selected, then go back to visual
    -- mode and run the command
    vim.cmd('normal! ' .. 'v' .. command)
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
