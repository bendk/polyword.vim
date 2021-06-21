local utils = require('polyword/utils')
local vim = require('polyword/vim')

local M = {}

-- s == "slash" or "special", easy way to prepend a backslash to a string
function M.s(name)
    return '\\' .. name
end
local s = M.s -- For ease of typing let's make it a local too

function M.any_char(...)
    return s'[' .. table.concat({...})  .. ']'
end

-- Some useful atoms
M.alpha = s'a'
M.digit = s'd'
M.dot = s'.'
M.lowercase = s'l'
M.uppercase = s'u'
M.alphanumeric = M.any_char('[:upper:][:lower:][:digit:]')
M.lowernumeric = M.any_char('[:lower:][:digit:]')
M.keyword = s'k'
M.word_start = s'<'
M.word_end = s'>'
M.word_end_char = s'.' .. s'>' -- last character of the word (the one preceding word_end)
M.cursor = s'%#'

function M.group(pattern)
    return s'(' .. pattern .. s')'
end

function M.atomize(pattern)
    if #pattern == 1 or (#pattern == 2 and pattern:sub(1, 1) == "\\") then
	return pattern
    else
	return M.group(pattern)
    end
end

function M.or_(...)
    return table.concat({...}, s'|')
end

function M.repeat_(pattern, opts)
    options = utils.get_options(opts, {greedy=true})

    local repeat_parts = { s'{'}
    if not options.greedy then table.insert(repeat_parts, '-') end
    if options.min then table.insert(repeat_parts, options.min) end
    table.insert(repeat_parts, ',')
    if options.max then table.insert(repeat_parts, options.max) end
    table.insert(repeat_parts, '}')
    return M.atomize(pattern) .. table.concat(repeat_parts)
end

function M.star(pattern, opts)
    return M.repeat_(pattern, utils.get_options(opts, {min=nil, max=nil}))
end

function M.plus(pattern, opts)
    return M.repeat_(pattern, utils.get_options(opts, {min=1, max=nil}))
end

function M.question(pattern, opts)
    return M.repeat_(pattern, utils.get_options(opts, {min=nil, max=1}))
end

function M.lookahead(pattern, opts)
    opts = utils.get_options(opts, {negative=false})

    if opts.negative then
	return M.atomize(pattern) ..  s'@!'
    else
	return M.atomize(pattern) ..  s'@='
    end
end

function M.lookbehind(pattern, opts)
    opts = utils.get_options(opts, {negative=false})

    if opts.negative then
	return M.atomize(pattern) ..  s'@<!'
    else
	return M.atomize(pattern) ..  s'@<='
    end
end

local normalize = s'V' .. s'C' -- very-nomagic and case-sensitive
function M.search(pattern, flags)
    pattern = normalize .. pattern
    -- For forward searches, start from the cursor position
    flags = 'W' .. flags
    if flags:find('b') == nil then flags = 'z' .. flags end
    return vim.search(pattern, flags) ~= 0
end

function M.searchpos(pattern, flags)
    pattern = normalize .. pattern
    flags = 'W' .. flags
    -- For forward searches, start from the cursor position
    if flags:find('b') == nil then flags = 'z' .. flags end
    return vim.searchpos(pattern, flags)
end

return M
