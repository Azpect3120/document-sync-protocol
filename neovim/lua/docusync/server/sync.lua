-- Imports
local events = require("docusync.parser.events")

-- Main update module
local M = {
  _settings = {
    commands = {
      -- { bufnr = cmd_id }
    }
  }
}

--- Starts an auto command to sync the document to
--- the clients with a set interval.
--- The timer will be returned which can be used in the main 
--- loop to stop the timer when the server is closed.
--- @param server Server Server object
--- @param document string Name of the document
--- @param bufnr integer Buffer number of the document
--- @return uv_timer_t timer The timer object used to stop the timer later
function M.start_sync_loop (server, document, bufnr)
  local timer = vim.loop.new_timer()

  -- Timeout in milliseconds
  local timeout = 1000

  -- Schedule interval to start
  timer:start(0, timeout, vim.schedule_wrap(function ()
    -- Check if the server should update the document
    if (server.f_update) then
      -- Construct the sync event without partial content
      local event = events.construct_sync_document(
        server,
        false,
        vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
        document,
        {},
        os.time()
      )

      -- Ensure server connection exists
      assert(server and server.tcp, "Error broadcasting: server or connection is nil")

      -- Loop through all connections and write the data
      for _, client in pairs(server.connections) do
        client:write(event)
      end

      -- Reset the update flag
      server.f_update = false
    end
  end))

  -- Return the timer
  return timer
end

--- Starts an auto command to update the document to
--- the server each time the file is saved.
--- @param server Server Server object
--- @param document string Name of the document
--- @param bufnr integer Buffer number of the document
--- @return integer
function M.on_save(server, document, bufnr)
  -- Create auto command
  local cmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("docusync", { clear = true }),
    pattern = document,
    desc = "Update servers document update flag",
    callback = function()
      -- Set the update flag to true
      server.f_update = true
    end
  })

  -- Save the command id in the settings
  -- This is used to delete the command later
  M._settings.commands[bufnr] = cmd_id

  -- Return the command id
  return cmd_id
end

--- Stop the auto command that updates the document on save
--- @param cmd_id integer ID of the auto command to delete
--- @return nil
function M.stop_on_save(cmd_id)
    vim.api.nvim_del_autocmd(cmd_id)
end


return M
