local utils = require('focus.modules.utils')
local M = {}

local golden_ratio = 1.618

local golden_ratio_width = function()
    local maxwidth = vim.o.columns
    return math.floor(maxwidth / golden_ratio)
end

local golden_ratio_minwidth = function()
    return math.floor(golden_ratio_width() / (3 * golden_ratio))
end

local golden_ratio_height = function()
    local maxheight = vim.o.lines
    return math.floor(maxheight / golden_ratio)
end

local golden_ratio_minheight = function()
    return math.floor(golden_ratio_height() / (3 * golden_ratio))
end

function M.autoresize(config)
    local width
    if config.autoresize.width > 0 then
        width = config.autoresize.width
    else
        width = golden_ratio_width()
        if config.autoresize.minwidth > 0 then
            width = math.max(width, config.autoresize.minwidth)
        elseif width < golden_ratio_minwidth() then
            width = golden_ratio_minwidth()
        end
    end

    local height
    if config.autoresize.height > 0 then
        height = config.autoresize.height
    else
        height = golden_ratio_height()
        if config.autoresize.minheight > 0 then
            height = math.max(height, config.autoresize.minheight)
        elseif height < golden_ratio_minheight() then
            height = golden_ratio_minheight()
        end
    end

    local win = vim.api.nvim_get_current_win()
    local view = vim.fn.winsaveview()
    local cur_h = vim.api.nvim_win_get_height(win)
    local cur_w = vim.api.nvim_win_get_width(win)

    if width > cur_w then
        vim.api.nvim_win_set_width(win, width)
    end
    if height > cur_h then
        vim.api.nvim_win_set_height(win, height)
    end
    vim.fn.winrestview(view)
end

function M.equalise()
    vim.api.nvim_exec2('wincmd =', { output = false })
end

function M.maximise()
    local width, height = vim.o.columns, vim.o.lines

    local win = vim.api.nvim_get_current_win()
    local view = vim.fn.winsaveview()
    vim.api.nvim_win_set_width(win, width)
    vim.api.nvim_win_set_height(win, height)
    vim.api.nvim_win_call(function()
        vim.fn.winrestview(view)
    end)
end

M.goal = 'autoresize'

function M.split_resizer(config, goal) --> Only resize normal buffers, set qf to 10 always
    if
        utils.is_disabled()
        or vim.api.nvim_win_get_option(0, 'diff')
        or vim.api.nvim_win_get_config(0).relative ~= ''
        or not config.autoresize.enable
    then
        vim.o.winwidth = 1
        vim.o.winminwidth = 1
        vim.o.winheight = 1
        vim.o.winminheight = 1
        return
    else
        if config.autoresize.minwidth > 0 then
            if vim.o.winwidth < config.autoresize.minwidth then
                vim.o.winwidth = config.autoresize.minwidth
            end
            vim.o.winminwidth = config.autoresize.minwidth
        end
        if config.autoresize.minheight > 0 then
            if vim.o.winheight < config.autoresize.minheight then
                vim.o.winheight = config.autoresize.minheight
            end
            vim.o.winminheight = config.autoresize.minheight
        end
    end

    if goal then
        M.goal = goal
    end

    if vim.bo.filetype == 'qf' and config.autoresize.height_quickfix > 0 then
        vim.api.nvim_win_set_height(0, config.autoresize.height_quickfix)
        return
    end

    M[M.goal](config)
end

return M
