require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- set by nvchad/starter, but I don;t like it
--map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

--M.general = {
--  n = {
--    [";"] = { ":", "enter command mode", opts = { nowait = true } },
--  },
--  v = {
--    [">"] = { ">gv", "indent"},
--  },
--}

map("v", ">", ">gv", { desc = "indent" })
map("v", "<", "<gv", { desc = "unindent" })
-- set by nvchad overriden by me
map("n", "<C-c>", "", { desc = "disabled" }) -- disables default

-- default for nerdtree, rewritten to ';' by me not sure if something else now uses C-n ?
map("n", "<C-n>", "", { desc = "toggle nvimtree" })
map("n", "<C-;>", "<cmd> NvimTreeToggle <CR>", { desc = "toggle nvimtree" })
