-- =================================================================
-- 1. SHARED CONFIGURATION (VS Code & Terminal)
-- =================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Sync clipboard with OS (Ctrl+C / Ctrl+V compatibility)
vim.opt.clipboard = "unnamedplus"

-- <leader>r: Reload Neovim config (for immediate Lua changes)
vim.keymap.set("n", "<leader>r", "<cmd>source $MYVIMRC<CR>", {
  noremap = true,
  silent = true,
  desc = "Reload Config",
})

-- =================================================================
-- 2. VS CODE SPECIFIC CONFIGURATION
-- =================================================================
if vim.g.vscode then
  -- Helper to call VS Code commands
  local function vscode_command(command)
    return string.format("<Cmd>call VSCodeNotify('%s')<CR>", command)
  end

  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- -----------------------------------------------------------
  -- SYSTEM & WINDOW MANAGEMENT
  -- -----------------------------------------------------------
  -- <leader>R: Reload the VS Code Window (to apply keybindings.json changes)
  keymap("n", "<leader>R", vscode_command("workbench.action.reloadWindow"), opts)
  -- <leader>w: Save file
  keymap("n", "<leader>w", vscode_command("workbench.action.files.save"), opts)
  -- <leader>q: Close current editor/tab
  keymap("n", "<leader>q", vscode_command("workbench.action.closeActiveEditor"), opts)
  -- <leader>qo: Close all OTHER editors (Focus current)
  keymap("n", "<leader>qo", vscode_command("workbench.action.closeOtherEditorGroups"), opts)

  -- -----------------------------------------------------------
  -- NAVIGATION (TABS & SPLITS)
  -- -----------------------------------------------------------
  -- Tab Switching (buffers) using H and L
  keymap("n", "L", vscode_command("workbench.action.nextEditor"), opts)
  keymap("n", "H", vscode_command("workbench.action.previousEditor"), opts)

  -- Focus specific Split (Pane)
  keymap("n", "<leader>h", vscode_command("workbench.action.focusLeftGroup"), opts)
  keymap("n", "<leader>l", vscode_command("workbench.action.focusRightGroup"), opts)
  keymap("n", "<leader>j", vscode_command("workbench.action.focusBelowGroup"), opts)
  keymap("n", "<leader>k", vscode_command("workbench.action.focusAboveGroup"), opts)

  -- -----------------------------------------------------------
  -- SPLIT MANAGEMENT
  -- -----------------------------------------------------------
  -- Create Splits
  keymap("n", "<leader>sv", vscode_command("workbench.action.splitEditor"), opts) -- Split Vertical
  keymap("n", "<leader>ss", vscode_command("workbench.action.splitEditorDown"), opts) -- Split Horizontal

  -- Move Current Editor TO a Split
  keymap("n", "<leader>sh", vscode_command("workbench.action.moveEditorToLeftGroup"), opts)
  keymap("n", "<leader>sl", vscode_command("workbench.action.moveEditorToRightGroup"), opts)
  keymap("n", "<leader>sk", vscode_command("workbench.action.moveEditorToAboveGroup"), opts)
  keymap("n", "<leader>sj", vscode_command("workbench.action.moveEditorToBelowGroup"), opts)

  -- -----------------------------------------------------------
  -- UI & SIDEBAR NAVIGATION
  -- -----------------------------------------------------------

  -- <leader>e: Switch to File Explorer Sidebar
  keymap("n", "<leader>e", vscode_command("workbench.view.explorer"), opts)

  -- <leader>f: Switch to Search Sidebar (Find in Files)
  keymap("n", "<leader>f", vscode_command("workbench.view.search"), opts)

  -- <leader>v: Switch to Source Control / Git Sidebar ("Version control")
  keymap("n", "<leader>v", vscode_command("workbench.view.scm"), opts)

  -- <leader>z: Toggle Sidebar Visibility
  -- (Hides/Shows whichever sidebar view is currently active)
  keymap("n", "<leader>z", vscode_command("workbench.action.toggleSidebarVisibility"), opts)

  -- -----------------------------------------------------------
  -- SEARCH & FILES
  -- -----------------------------------------------------------
  -- <leader>f: Find File (Quick Open)
  keymap("n", "<leader>f", vscode_command("workbench.action.quickOpen"), opts)

  -- <leader>sg: Global Text Search (Find in Files)
  keymap("n", "<leader>sg", vscode_command("workbench.action.findInFiles"), opts)

  -- <leader>sf: Just focus the search panel
  keymap("n", "<leader>sf", vscode_command("workbench.view.search"), opts)

  -- -----------------------------------------------------------
  -- RESTORE QUICK OPEN
  -- -----------------------------------------------------------
  -- Since <leader>f is now the Search Sidebar, let's map Quick Open
  -- (fuzzy find files) to <leader><space>, just like LazyVim.
  keymap("n", "<leader><space>", vscode_command("workbench.action.quickOpen"), opts)
else
  -- =================================================================
  -- 3. TERMINAL NEOVIM CONFIGURATION
  -- =================================================================
  -- Put your lazy.nvim or other plugins here
  require("config.lazy")
end
