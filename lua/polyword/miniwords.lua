local re = require('polyword/re')
local utils = require('polyword/utils')
local M = {}

-- Name that's been parsed into individual mini-words
local Name = {}
Name.__index = Name

function Name:new(config)
    return setmetatable({
	line = config.line,
	startcol = config.startcol,
	endcol = config.endcol,
	words = config.words,
    }, self)
end

function Name:iter_word_pos(idx)
    local i = 1
    return function()
	local rv
	if self.words[i] then
	    rv = self.words[i][idx]
	    i = i+1
	end
	return rv
    end
end

function Name:motion_forward(pos_iter)
    local col = vim.fn.col('.')
    for pos in pos_iter do
	if pos > col then
	    vim.fn.setpos('.', {0, self.line, pos, 0})
	    return
	end
    end
    vim.fn.setpos('.', {0, self.line, self.endcol + 1, 0})
end

function Name:motion_backward(pos_iter)
    local col = vim.fn.col('.')
    local move_to = nil
    for pos in pos_iter do
	if pos < col then move_to = pos else break end
    end
    if move_to ~= nil then
	vim.fn.setpos('.', {0, self.line, move_to, 0})
    else
    vim.fn.setpos('.', {0, self.line, self.startcol - 1, 0})
    end
end

function Name:text_object(extend)
    local col = vim.fn.col('.')
    for i, word in pairs(self.words) do
	if word[1] <= col and word[2] >= col then
	    local startcol = word[1]
	    local endcol = word[2]
	    if extend then
		if self.words[i+1] ~= nil then
		    endcol = self.words[i+1][1] - 1
		elseif self.words[i-1] ~= nil then
		    startcol = self.words[i-1][2] + 1
		end
	    end
	    utils.visual_select(self.line, startcol, self.line, endcol)
	end
    end
end

--  maps type names to the regexes we need to create Names from them
local name_type_patterns = {
    camel = {
	valid_chars = re.alphanumeric,
	tester = re.Matcher:new(re.or_(
	    -- aA transition anywhere
	    re.lowercase .. re.uppercase,
	    -- Aa transition anywhere after the first char
	    re.uppercase .. re.lowercase
	)),
	word_matcher = re.Matcher:new(re.dot .. re.star(re.lowernumeric)),
    },
    snake = {
	valid_chars = re.any_char('[:upper:][:lower:][:digit:]_'),
	word_matcher = re.Matcher:new(re.lookbehind(re.star('_')) .. re.plus(re.alphanumeric)),
    },
    kebab = {
	valid_chars = re.any_char('[:upper:][:lower:][:digit:]-'),
	word_matcher = re.Matcher:new(re.lookbehind(re.star('-')) .. re.plus(re.alphanumeric)),
    },
}

local function parse_type(name)
    local patterns = name_type_patterns[name]
    local startpos = re.searchpos(re.star(patterns.valid_chars) .. re.cursor .. patterns.valid_chars, 'bcn')
    local endpos = re.searchpos(re.cursor .. re.plus(patterns.valid_chars), 'ecn')
    local config = {
	line = startpos[1],
	startcol = startpos[2],
	endcol = endpos[2],
	words = {},
    }
    if config.startcol == 0 or config.endcol == 0 then return end
    local pos = config.startcol
    local after_end = config.endcol + 1
    if patterns.tester and not patterns.tester:match_line(config.line, pos, after_end) then return nil end
    while true do
	local match = patterns.word_matcher:match_line(config.line, pos, after_end)
	if match == nil then
	    break
	else
	    table.insert(config.words, {match[1], match[2]-1})
	    -- Subtract 1 to make the endcol inside the word rather than after it
	    pos = match[2]
	end
    end
    if #config.words >= 2 then return Name:new(config) else return nil end
end

M.type_order = {"camel", "snake", "kebab"}

function M.is_type_at_cursor(name)
    return parse_type(name) ~= nil
end

local any_name_char = re.any_char('[:upper:][:lower:][:digit:]_-')

function M.get_name(direction)
    local rv = nil
    local startpos = vim.fn.getpos('.')
    if direction == 'backward' then
	re.search(any_name_char, 'bc')
    elseif direction == 'forward' then
	re.search(any_name_char, 'c')
    end

    for _, name in pairs(M.type_order) do
	local name = parse_type(name)
	if name ~= nil then
	    rv = name
	    break
	end
    end
    vim.fn.setpos('.', startpos)
    return rv
end

function M.miniword(command)
    local name
    if command == 'w' or command == 'e' then
	name = M.get_name('forward')
    elseif command == 'b' or command == 'ge' then
	name = M.get_name('backward')
    else
	name = M.get_name()
    end
    if name == nil then
	-- default to normal word command
	if utils.command_is_motion(command) then
	    vim.cmd('normal! ' .. command)
	elseif utils.command_is_text_object(command) then
	    utils.visual_select_with_command(command)
	end
	return
    end

    if command == 'w' then
	name:motion_forward(name:iter_word_pos(1))
    elseif command == 'e' then
	name:motion_forward(name:iter_word_pos(2))
    elseif command == 'b' then
	name:motion_backward(name:iter_word_pos(1))
    elseif command == 'ge' then
	name:motion_backward(name:iter_word_pos(2))
    elseif command == 'iw' then
	name:text_object(false)
    elseif command == 'aw' then
	name:text_object(true)
    end
end

function M.split_word_at_cursor()
    local name = M.get_name()
    if name == nil then return nil end

    local line = vim.fn.getline('.')
    local words = {}
    for _, wordpos in pairs(name.words) do
	table.insert(words, line:sub(wordpos[1], wordpos[2]))
    end
    return {
	line = name.line,
	startcol = name.startcol,
	endcol = name.endcol,
	words = words,
	word_positions = name.words,
    }
end

return M

