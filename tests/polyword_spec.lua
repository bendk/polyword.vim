local miniwords = require('polyword.miniwords')
local transform = require('polyword.transform').transform

-- Setup some mappings for testing
vim.cmd([[
map ,w  <plug>(polyword-miniword-w)
map ,b  <plug>(polyword-miniword-b)
map ,e  <plug>(polyword-miniword-e)
map ,ge <plug>(polyword-miniword-ge)
omap im <plug>(polyword-miniword-iw)
omap am <plug>(polyword-miniword-aw)

map W <plug>(polyword-megaword-w)
map B <plug>(polyword-megaword-b)
map E <plug>(polyword-megaword-e)
map gE <plug>(polyword-megaword-ge)
omap iW <plug>(polyword-megaword-iw)
omap aW <plug>(polyword-megaword-aw)
]])

function get_char_at_cursor()
    local col = vim.fn.col('.')
    return vim.fn.getline('.'):sub(col, col)
end

describe("identification", function()
    -- Meta note: For all of these, a positive identification means finding at
    -- least 2 words separated with the proper syntax
    --
    local function test_identification(naming_type, content, chars_inside_words)
        vim.fn.setline(1, content)

        for i=1,#content do
            vim.fn.cursor(1, i)
            if chars_inside_words:sub(i, i) == 'X' then
                assert(miniwords.is_type_at_cursor(naming_type), string.format('Expected positive ID at char %s', i))
            else
                assert(not miniwords.is_type_at_cursor(naming_type), string.format('Expected negative ID at char %s', i))
            end
        end
    end

    it('finds snake case words', function()
        test_identification(
            'snake',
            ' my_var __my_var__ _my var__',
            ' XXXXXX XXXXXXXXXX           '
        )
    end)

    it('finds kebab case words', function()
        test_identification(
            'kebab',
            ' my-var --my-var-- -my var--',
            ' XXXXXX XXXXXXXXXX           '
        )
    end)

    it('finds camel case and pascal case words', function()
        test_identification(
            'camel',
            ' myVar MyVar My var',
            ' XXXXX XXXXX        '
        )
    end)

    it('handles edge cases with camel case', function()
        test_identification(
            'camel',
            'aaa aaA aAa Aaa aAA AAa AAA',
            '    XXX XXX     XXX XXX    '
        )
    end)
end)

local function test_motion_endpoint(command, content, expected_target_char)
    vim.fn.setline(1, content)

    for i=1,#content do
        vim.fn.cursor(1, i)
        vim.cmd('normal ' .. command)
        assert.equals(string.sub(expected_target_char, i, i), get_char_at_cursor(),
            string.format("Error with motion %s from char %s", command, i))
    end
end

describe("miniword motions", function()
    it("handles snake case", function()
        test_motion_endpoint(
            ",w",
            "(__abc_DEF___ghi_)", 
            "aaaDDDDgggggg)))))"
        )

        test_motion_endpoint(
            ",b",
            "(__abc_DEF___ghi_)", 
            "((((aaaaDDDDDDgggg"
        )

        test_motion_endpoint(
            ",e",
            "(__abc_DEF___ghi_)", 
            "cccccFFFFiiiiii)))"
        )

        test_motion_endpoint(
            ",ge",
            "(__abc_DEF___ghi_)", 
            "((((((ccccFFFFFFii"
        )
    end)

    it("handles kebab case", function()
        test_motion_endpoint(
            ",w",
            "(abc-DEF--ghi-)", 
            "aDDDDggggg)))))"
        )

        test_motion_endpoint(
            ",b",
            "(abc-DEF--ghi-)", 
            "((aaaaDDDDDgggg"
        )

        test_motion_endpoint(
            ",e",
            "(abc-DEF--ghi-)", 
            "cccFFFFiiiii)))"
        )

        test_motion_endpoint(
            ",ge",
            "(abc-DEF--ghi-)", 
            "((((ccccFFFFFii"
        )
    end)

    it("handles camel case", function()
        test_motion_endpoint(
            ",w",
            "(abcDefGHi)", 
            "aDDDGGGH)))"
        )

        test_motion_endpoint(
            ",b",
            "(abcDefGHi)", 
            "((aaaDDDGHH"
        )

        test_motion_endpoint(
            ",e",
            "(abcDefGHi)", 
            "cccfffGii))"
        )

        test_motion_endpoint(
            ",ge",
            "(abcDefGHi)", 
            "((((cccfGGi"
        )
    end)

    it('defaults to word motion', function()
        test_motion_endpoint(
            ",w",
            "abc def ghi",
            "ddddggggiii"
        )

        test_motion_endpoint(
            ",b",
            "abc def ghi",
            "aaaaaddddgg"
        )

        test_motion_endpoint(
            ",e",
            "abc def ghi",
            "ccffffiiiii"
        )

        test_motion_endpoint(
            ",ge",
            "abc def ghi",
            "aaaccccffff"
        )
    end)
end)

describe("megaword motions", function()
    it('moves by megawords', function()
        test_motion_endpoint(
            "W",
            "(abc.def.ghi jkl)",
            "ajjjjjjjjjjjj))))"
        )

        test_motion_endpoint(
            "B",
            "(abc.def.ghi jkl)",
            "((aaaaaaaaaaaajjj"
        )

        test_motion_endpoint(
            "E",
            "(abc.def.ghi jkl)",
            "iiiiiiiiiiillll))"
        )

        test_motion_endpoint(
            "gE",
            "(abc.def.ghi jkl)",
            "((((((((((((iiiil"
        )
    end)

end)

describe("text objects", function()
    local function run_operation(content, pos, command)
        vim.fn.setline(1, content)
        vim.fn.setpos('.', {0, 1, pos, 0})
        vim.cmd("normal " .. command)
        return vim.fn.getline(1)
    end

    it("selects with mini words", function()
        assert.equals("aaa__ccc", run_operation("aaa_bbb_ccc", 6, "dim"))
        assert.equals("aaa_ccc", run_operation("aaa_bbb_ccc", 6, "dam"))
    end)

    it("miniword select defaults to word", function()
        assert.equals("aaa  ccc", run_operation("aaa bbb ccc", 6, "dim"))
        assert.equals("aaa ccc", run_operation("aaa bbb ccc", 6, "dam"))
    end)

    it("selects with mega words", function()
        assert.equals(" four", run_operation("one.two.three four", 6, "diW"))
        assert.equals("four", run_operation("one.two.three four", 6, "daW"))
    end)
end)

describe("case transforms", function()
    local function run_transform(naming_type, content, pos)
        vim.fn.setline(1, content)
        vim.fn.setpos('.', {0, 1, pos, 0})
        transform(naming_type)
        return vim.fn.getline(1)
    end

    it("transforms one naming type to another", function()
        assert.equals("abcDefGhi", run_transform("camel", "__abc_DEF___ghi_", 1))
        assert.equals("AbcDefGhi", run_transform("pascal", "__abc_DEF___ghi_", 1))
        assert.equals("abc-def-ghi", run_transform("kebab", "abc_DEF_ghi", 1))
        assert.equals("abc_def_ghi", run_transform("snake", "abc-def-ghi", 1))
        assert.equals("ABC_DEF_GHI", run_transform("snake-upper", "abc-def-ghi", 1))
    end)

    it("preserves surrounding non-word chars", function()
        assert.equals("  abcDefGhi(2)", run_transform("camel", "  __abc_DEF___ghi_(2)", 3))
        assert.equals("  one_two_three(2)", run_transform("snake", "  OneTwoThree(2)", 3))
    end)

    it("preserves the separator count when going from snake to kebab", function()
        assert.equals("_abc__def___ghi", run_transform("snake", "-abc--def---ghi", 1))
        assert.equals("-abc--def---ghi", run_transform("kebab", "_abc__def___ghi", 1))
    end)
end)
