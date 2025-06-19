-- lua dofile("/home/thomas/plugins/present.nvim/lua/present.lua")
local M = {}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 1)
  local height = opts.height or math.floor(vim.o.lines * 1)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

M.setup = function()
  print("Setting up present.nvim plugin...")
  -- Set up the present.nvim plugin with default options
end

---@class present.Slides
---@field slides present.Slide[]: The slides of the file

---@class present.Slide
---@field title string: The title of the slide
---@field body string: The body of the slide

--- Takes some lines and parses them
---@param lines string[]: The lines in the buffer
---@return present.Slides
local parse_slides = function(lines)
  local slides = { slides = {} }
  local current_slide = {}

  local separator = "^#"

  for _, line in ipairs(lines) do
    if line:find(separator) then
      if #current_slide > 0 then
        table.insert(slides.slides, current_slide)
      end

      current_slide = {}
    end

    table.insert(current_slide, line)
  end

  table.insert(slides.slides, current_slide)

  return slides
end

M.start_presentation = function(opts)
  opts = opts or {}
  opts.bufnr = opts.bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
  local parsed = parse_slides(lines)
  local float = create_floating_window()

  -- KEYMAPS
  local current_slide = 1
  vim.keymap.set("n", "<A-n>", function()
    current_slide = math.min(current_slide + 1, #parsed.slides)
    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
  end)

  vim.keymap.set("n", "<A-p>", function()
    current_slide = math.max(current_slide - 1, 1)
    vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
  end)

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(float.win, true)
  end)

  -- AUTOCOMMANDS
  local user_options = {
    cmdheight = { original = vim.o.cmdheight, plugin = 0 },
  }

  -- Set options we want for presentation
  for option, config in pairs(user_options) do
    vim.opt[option] = config.plugin
  end

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = float.buf,
    callback = function()
      for option, config in pairs(user_options) do
        vim.opt[option] = config.original
      end
    end,
  })

  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

M.start_presentation({ bufnr = 27 })

-- vim.print(parse_slides({
--   "# Hello World",
--   "this is something else",
--   "# World",
--   "thid is another thing",
-- }))

return M
