local miniwords = require('polyword.miniwords')
local vim = require('polyword.vim')

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
local last_transform_type = nil

function M.transform(transform_type)
    -- Setup the operatorfunc and execute it.  This works with dot-repeat.
    last_transform_type = transform_type
    vim.go.operatorfunc = "v:lua.require'polyword.transform'.do_transform"
    vim.cmd("normal! g@l")
end

function M.do_transform(transform_type)
    local word_split = miniwords.split_word_at_cursor()
    local transform_func = transformers[last_transform_type]

    if word_split ~= nil and transform_func ~= nil then
        local new_text = transform_func(word_split)
        vim.setline(word_split.line, word_split.startcol, word_split.endcol, new_text)
    end
end

return M
