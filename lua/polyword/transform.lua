local miniwords = require('polyword.miniwords')

local M = {}

local function titlecase(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
end

local function camel_or_pascal(word_split, first_word_transform)
    local parts = {}
    for i, word in pairs(word_split.words) do
	if i == 1 then
	    table.insert(parts, first_word_transform(word))
	else
	    table.insert(parts, titlecase(word))
	end
    end
    return table.concat(parts)
end

local function snake_or_kebab(word_split, separator, word_transform)
    local parts = {}
    local last_endpos = word_split.startcol
    for i, word in pairs(word_split.words) do
	leading_width = word_split.word_positions[i][1] - last_endpos
	if leading_width > 0 then
	    table.insert(parts, string.rep(separator, leading_width))
	elseif i > 1 then
	    table.insert(parts, separator)
	end
	table.insert(parts, word_transform(word))
	last_endpos = word_split.word_positions[i][2] + 1
    end
    trailing_width = word_split.word_positions[#word_split.word_positions][1] - last_endpos
    if trailing_width > 0 then table.insert(parts, string.rep(separator, trailing_width)) end
    return table.concat(parts)
end

local transformers = {
    camel = function(word_split) return camel_or_pascal(word_split, string.lower) end,
    pascal = function(word_split) return camel_or_pascal(word_split, titlecase) end,
    snake = function(word_split) return snake_or_kebab(word_split, '_', string.lower) end,
    kebab = function(word_split) return snake_or_kebab(word_split, '-', string.lower) end,
    ["snake-upper"] = function(word_split) return snake_or_kebab(word_split, '_', string.upper) end,
    ["kebab-upper"] = function(word_split) return snake_or_kebab(word_split, '-', string.upper) end,
}

function M.transform(transform_type)
    local word_split = miniwords.split_word_at_cursor()
    local transform_func = transformers[transform_type]

    if word_split ~= nil and transform_func ~= nil then
	local new_text = transform_func(word_split)
	vim.api.nvim_buf_set_text(0, word_split.line-1, word_split.startcol-1, word_split.line-1, word_split.endcol, {new_text})
    end
end

return M
