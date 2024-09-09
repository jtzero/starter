-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

-- this line is the new one, not usre id the old one is needed
M.base46 = {
  theme = "chadracula",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}
M.ui = {
  italic_comments = false,

  -- theme to be used, to see all available themes, open the theme switcher by <leader> + th
  -- telescope themes current theme is saved here
  -- with the new version this doesn't appear to get updated ?
  theme = "chadracula",
  -- not sure this is needed anymore
  -- theme toggler, toggle between two themes, see theme_toggleer mappings
  theme_toggler = {
     enabled = false,
     fav_themes = {
        "chadracula",
        "gruvchad"
     },
  },

  -- Enable this only if your terminal has the colorscheme set which nvchad uses
  -- For Ex : if you have chadracula set in nvchad , set chadracula's bg color on your terminal
  transparency = false,
  --statusline = {
  --  theme = "override",
  --},
  nvdash = {
    load_on_startup = true,
  }
}

local custom_package_path = vim.fs.dirname(debug.getinfo(1).source):sub(2)

if not string.find(package.path, custom_package_path) then
  package.path = package.path .. ";" .. custom_package_path .. '/?.lua'
end

return M
