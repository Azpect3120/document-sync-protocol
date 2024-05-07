-- Title:        DocuSync.nvim
-- Description:  A plugin that allows you to sync your documents in your editor with other editors.
-- Last Change:  23 April 2024
-- Maintainer:   Azpect3120 <https://github.com/Azpect3120>

-- Prevents the plugin from being loaded multiple times. If the loaded
-- variable exists, do nothing more. Otherwise, assign the loaded
-- variable and continue running this instance of the plugin.
if not _G.myPluginLoaded then
  -- Create a command to connect to the DocuSync server
  vim.api.nvim_create_user_command(
    "DocuSyncConnect",
    function (opts)
      local host, port = opts.fargs[1], opts.fargs[2]
      require("docusync").connect(host, port)
    end,
    { nargs = "*" }
  )

  -- Create a command to disconnect from the DocuSync server
  vim.api.nvim_create_user_command(
    "DocuSyncDisconnect",
    function (_)
      require("docusync").disconnect()
    end,
    { nargs = 0 }
  )

  -- Create a command to start the DocuSync server
  vim.api.nvim_create_user_command(
    "DocuSyncStartServer",
    function (opts)
      local host, port = opts.fargs[1], opts.fargs[2]
      require("docusync").start_server(host, port)
    end,
    { nargs = "*" }
  )

  -- Create a command to stop the DocuSync server
  vim.api.nvim_create_user_command(
    "DocuSyncStopServer",
    function (_)
      require("docusync").stop_server()
    end,
    { nargs = 0 }
  )

  -- Create a command to get the document list
  vim.api.nvim_create_user_command(
    "DocuSyncDocumentList",
    function (_)
      require("docusync").document_list()
    end,
    { nargs = 0 }
  )

  -- Create a command to dump the DocuSync server data
  vim.api.nvim_create_user_command(
    "DocuSyncDumpServer",
    function (_)
      require("docusync").dump_server()
    end,
    { nargs = 0 }
  )

  -- Create a command to dump the DocuSync client data
  vim.api.nvim_create_user_command(
    "DocuSyncDumpClient",
    function (_)
      require("docusync").dump_client()
    end,
    { nargs = 0 }
  )

  -- Create a command to run the DocuSync testing suite
  vim.api.nvim_create_user_command(
    "DocuSyncTest",
    function (_)
      require("docusync").test_suite()
    end,
    { nargs = 0 }
  )

  -- Ensure plugin is only loaded once
  _G.myPluginLoaded = true
end
