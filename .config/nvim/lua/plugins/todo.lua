return {
    {
        'folke/todo-comments.nvim',
        config = function()
            local todo = require('todo-comments')
            todo.setup {}

            local wk = require('which-key')

            local jump_next_fixme = function()
                todo.jump_next({ keywords = { 'FIX' } })
            end

            local jump_prev_fixme = function()
                todo.jump_prev({ keywords = { 'FIX' } })
            end

            wk.add({
                { ']t', todo.jump_next,  mode = 'n', desc = "Jump to next TODO" },
                { '[t', todo.jump_prev,  mode = 'n', desc = "Jump to prev TODO" },
                { ']f', jump_next_fixme, mode = 'n', desc = "Jump to next FIXME" },
                { '[f', jump_prev_fixme, mode = 'n', desc = "Jump to prev FIXME" },
            })
        end,
    },
}
