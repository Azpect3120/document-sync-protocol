-- Title:        DocuSync.nvim
-- Description:  A plugin that allows you to sync your documents in your editor with other editors.
-- Last Change:  23 April 2024
-- Maintainer:   Azpect3120 <https://github.com/Azpect3120>

-- Prevents the plugin from being loaded multiple times. If the loaded
-- variable exists, do nothing more. Otherwise, assign the loaded
-- variable and continue running this instance of the plugin.
if not _G.myPluginLoaded then
  -- Exposes the plugin's functions for use as commands in Neovim.

  -- Ensure plugin is only loaded once
  _G.myPluginLoaded = true
end
