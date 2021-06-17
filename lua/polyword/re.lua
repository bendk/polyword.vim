local utils = require('polyword/utils')

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
    return vim.fn.search(pattern, flags) ~= 0
end

function M.searchpos(pattern, flags)
    pattern = normalize .. pattern
    flags = 'W' .. flags
    -- For forward searches, start from the cursor position
    if flags:find('b') == nil then flags = 'z' .. flags end
    return vim.fn.searchpos(pattern, flags)
end

-- Create a matcher object, which can be used to match a pattern against editor text
M.Matcher = {}
M.Matcher.__index = M.Matcher

function M.Matcher:new(pattern)
    return setmetatable({
	regex = vim.regex(normalize .. pattern)
    }, self)
end

function M.Matcher:match_line(row, startcol, endcol)
    -- Convert from 1-based to 0-based
    row = row - 1
    if startcol ~= nil then startcol = startcol - 1 end
    if endcol ~= nil then endcol = endcol - 1 end
    local match_start, match_end = self.regex:match_line(0, row, startcol, endcol)
    if match_start == nil then
	return nil
    else
	return { startcol + match_start + 1, startcol + match_end + 1 } -- Convert from 0-based to 1-based
    end
end

return M
