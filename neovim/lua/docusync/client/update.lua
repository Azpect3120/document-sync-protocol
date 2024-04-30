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

--- Starts an auto command to update the document to
--- the server each time the file is saved.
--- @param conn Connection Connection class from main data module
--- @param document string Name of the document
--- @param identifier string Identifier of the document ("" if none)
--- @param bufnr integer Buffer number of the document
--- @return integer
function M.on_save(conn, document, identifier, bufnr)
  -- Create auto command
  local cmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("docusync", { clear = true }),
    pattern = document, -- Only run when the target document is saved
    desc = "Update document to server",
    callback = function()
      -- Construct the sync document event
      local event = events.construct_update_document(
        false,
        identifier,
        vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
        document,
        nil,
        os.time()
      )

      -- Send the event to the server if the connection is active
      if (conn.tcp:is_active()) then
        local _ = conn.tcp:try_write(event)
        -- print("Updated document on the server! Bytes sent: " .. bytes)
      else
        -- Stop the connection
        vim.schedule(function()
          conn.tcp:close(function(err) assert(not err, err) end)
          conn.tcp:shutdown(function(err) assert(not err, err) end)
          conn.tcp = nil
        end)

        -- Delete the auto command
        local cmd_id = M._settings.commands[bufnr]

        -- Check if the command exists and delete it if it does
        if cmd_id then
          vim.api.nvim_del_autocmd(cmd_id)
        end

        -- Print error message
        error("Connection is no longer active. Connection has been terminated")
      end
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
