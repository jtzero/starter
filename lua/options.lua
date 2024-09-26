require "nvchad.options"

-- add yours here!

--local opt = vim.opt
--opt.clipboard = "unnamedplus"

vim.cmd('source ~/.vimrc-init')


-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
--

-- doesn;t work in the theme preview for some reason
vim.api.nvim_create_autocmd({"BufEnter", "BufRead"}, {
  callback = function()
    local theme = require("nvconfig").ui.theme
    if theme == "chadracula" then
      vim.api.nvim_set_hl(0, '@string.special.symbol.ruby', { fg = '#f1f18c' })
    --elseif theme == 'onenord_light' then
    -- only works for in a gui, for iterm2 use "Cursor Colors" > "Smart box Cursor color"
    --  vim.api.nvim_set_hl(0, "Cursor", {fg='black', bg='black'})
    end
  end,
  --group = my_buf_enter_group,
})
