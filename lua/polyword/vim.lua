-- Vim functionality wrapper
--
-- This module exists to provide a simple interface to vim functionality that abstracts away the differences between vim and nvim

local M = {}

local on_nvim = vim.fn.has('nvim') ~= 0

M.go = vim.go
M.fn = vim.fn
M.col = vim.fn.col
M.getline = vim.fn.getline
M.nr2char = vim.fn.nr2char
M.searchpos = vim.fn.searchpos
M.search = vim.fn.search
M.winrestview = vim.fn.winrestview
M.winsaveview = vim.fn.winsaveview
M.keycodes = {
    PLUG = "\128\253S",
}

if on_nvim then
    M.setpos = vim.fn.setpos
    M.cmd = vim.cmd

    function M.setline(line, startcol, endcol, new_text)
        vim.api.nvim_buf_set_text(0, line-1, startcol-1, line-1, endcol, {new_text})
    end

    function M.opt_get(name)
        return vim.opt[name]
    end

    function M.opt_append(name, value)
        return vim.opt[name]:append(value)
    end

    function M.opt_set(name, value)
        vim.opt[name] = value
    end

    function M.var_get(name)
        return vim.v[name]
    end
else
    function M.setpos(where, pos)
        vim.fn.setpos(where, vim.list(pos))
    end
    M.cmd = vim.command
    function M.setline(line, startcol, endcol, new_text)
        local line_text = vim.fn.getline(line)
        line_text = line_text:sub(1, startcol-1) .. new_text .. line_text:sub(endcol+1, -1)
        vim.fn.setline(line, line_text)
    end

    function M.opt_get(name)
        return vim.eval('&' .. name)
    end

    function M.opt_append(name, value)
        return vim.command("set " .. name .. "+=" .. value)
    end

    function M.opt_set(name, value)
        return vim.command("set " .. name .. "=" .. value)
    end

    function M.var_get(name)
        return vim.eval("v:" .. name)
    end
end

return M
