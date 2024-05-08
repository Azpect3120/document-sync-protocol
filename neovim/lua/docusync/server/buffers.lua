-- server/buffers.lua module
local M = {}

--- Begin the buffer handling for the server. This include setting up the
--- watcher to add buffers to the server. This function will setup autocommands
--- to listen for buffer events. This function should also include any events
--- being sent to the clients to notify them of the buffer changes.
--- @param server Server The server object to attach to.
--- @return nil
function M.listen(server)
  -- Buffer ADD listener
  vim.api.nvim_create_autocmd("BufAdd", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_add", { clear = true }),
    pattern = "*",
    callback = function(event)
      -- Add buffer to the server data
      local bufnr = event.buf
      local cwd = vim.loop.cwd()
      local bufname_long = vim.api.nvim_buf_get_name(bufnr)

      -- Ignore oil buffers
      if (string.sub(bufname_long, 1, 7) == "oil:///") then return end

      -- Get the buffer name relative to the current working directory
      local bufname = string.sub(bufname_long, #cwd + 2, #bufname_long)

      -- Ignore empty buffer names
      if (bufname == "") then return end

      -- Add the buffer to the server data
      server.data.buffers[bufname] = bufnr


      -- Create document/open notification
      local notification = require("docusync.server.events.constructor").notifications.document_open(bufname)

      -- Write the event to all connected clients and disconnect any inactive connections
      for _, connection in pairs(server.connections) do
        if connection:is_active() then
          connection:write(notification, function(err) assert(not err, err) end)
        else
          server.connections[connection] = nil
        end
      end
    end
  })

  -- Buffer DELETE listener
  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_delete", { clear = true }),
    pattern = "*",
    callback = function(event)
      local bufnr = event.buf
      local cwd = vim.loop.cwd()
      local bufname_long = vim.api.nvim_buf_get_name(bufnr)

      -- Ignore oil buffers
      if (string.sub(bufname_long, 1, 7) == "oil:///") then
        return
      end

      -- Get the buffer name relative to the current working directory
      local bufname = string.sub(bufname_long, #cwd + 2, #bufname_long)

      -- Remove the buffer from the server data
      server.data.buffers[bufname] = nil

      -- Create document/close event
      local notification = require("docusync.server.events.constructor").notifications.document_close(bufname)

      -- Write the event to all connected clients
      for _, connection in pairs(server.connections) do
        if connection:is_active() then
          connection:write(notification, function(err) assert(not err, err) end)
        else
          server.connections[connection] = nil
        end
      end
    end
  })

  -- Buffer ENTER listener
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_enter", { clear = true }),
    pattern = "*",
    callback = function(event)
      -- Add buffer to the server data
      local bufnr = event.buf
      local cwd = vim.loop.cwd()
      local bufname_long = vim.api.nvim_buf_get_name(bufnr)

      -- Ignore oil buffers
      if (string.sub(bufname_long, 1, 7) == "oil:///") then return end

      -- Get the buffer name relative to the current working directory
      local bufname = string.sub(bufname_long, #cwd + 2, #bufname_long)

      -- Ignore empty buffer names
      if (bufname == "") then return end

      -- Spawn the attach listener for the server buffer
      vim.api.nvim_buf_attach(bufnr, false, {
        on_bytes = function()
          -- Get the lines from the buffer
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

          -- Create the document/sync notification
          local sync_event = require("docusync.server.events.constructor").events.document_sync(bufname, lines)

          -- Write the event to all connected clients and disconnect any inactive connections
          for _, connection in pairs(server.connections) do
            if connection:is_active() then
              connection:write(sync_event, function(err) assert(not err, err) end)
            else
              server.connections[connection] = nil
            end
          end
        end,
      })
    end
  })

  -- Buffer LEAVE listener
  vim.api.nvim_create_autocmd("BufLeave", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_leave", { clear = true }),
    pattern = "*",
    callback = function()
      local bufname = vim.fn.expand("%", true)
      -- print("Server is no longer active in buffer: " .. bufname)
    end
  })
end

-- Return the module
return M
