-- Prompts the user for a note title
local function prompt_new_note()
    local canceledStr = "__INPUT_CANCELLED__"

    vim.ui.input({
        prompt = "Title: ",
        cancelreturn = canceledStr,
        completion = "file",
    }, function(title)
        if not title then
            title = ""
        end
        if title == canceledStr then
            vim.cmd("echohl WarningMsg")
            vim.cmd("echomsg 'Note creation cancelled!'")
            vim.cmd("echohl None")
        else
            vim.cmd("ObsidianNew " .. title)
        end
    end)
end


return {
    {
        'epwalsh/obsidian.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        init = function()
            local wk = require('which-key')
            wk.add({
                { '<Leader>n',  group = "Notes" },
                { '<Leader>nn', prompt_new_note,                mode = 'n', desc = 'New note' },
                { '<Leader>ns', '<cmd>ObsidianSearch<CR>',      mode = 'n', desc = 'Search notes' },
                { '<Leader>nf', '<cmd>ObsidianQuickSwitch<CR>', mode = 'n', desc = 'Search notes by filename' },
                { '<Leader>nt', '<cmd>ObsidianToday<CR>',       mode = 'n', desc = 'Today\'s note' },
                { '<Leader>nm', '<cmd>ObsidianTomorrow<CR>',    mode = 'n', desc = 'Tomorrow\'s note' },
                { '<Leader>ny', '<cmd>ObsidianYesterday<CR>',   mode = 'n', desc = 'Yesterday\'s note' },
                { '<Leader>np', '<cmd>ObsidianPasteImg<CR>',    mode = 'n', desc = 'Paste image from clipboard' },
                { '<Leader>ng', '<cmd>ObsidianFollowLink<CR>',  mode = 'n', desc = 'Follow link under cursor' },
                { '<Leader>ng', '<cmd>ObsidianLink<CR>',        mode = 'n', desc = 'Link to an existing note' },
                { '<Leader>ng', '<cmd>ObsidianLinkNew<CR>',     mode = 'n', desc = 'Link to a new note' },
            })
        end,
        opts = {
            workspaces = {
                {
                    name = "personal",
                    path = "~/Documents/personal",
                },
            },
            notes_subdir = 'notes',
            daily_notes = {
                folder = 'notes/daily',
                date_format = "%Y-%m-%d",
                alias_format = "%B %-d, %Y",
            },
            note_id_func = function(title)
                local suffix = ""
                if title ~= nil then
                    suffix = title:gsub(" ", "_"):gsub("[^A-Za-z0-9-]", "_"):lower()
                else
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                return tostring(os.time()) .. "-" .. suffix
            end,
            wiki_link_func = function(opts)
                if opts.id == nil then
                    return string.format("[[%s]]", opts.label)
                elseif opts.label ~= opts.id then
                    return string.format("[[%s|%s]]", opts.id, opts.label)
                else
                    return string.format("[[%s]]", opts.id)
                end
            end,
            ui = {
                enable = true,
            },
            new_notes_location = 'notes_subdir',
            completion = {
                nvim_cmp = true,
                min_chars = 2,
            },
        },
    }
}
