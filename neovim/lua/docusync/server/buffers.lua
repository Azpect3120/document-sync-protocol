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
      local bufname = vim.fn.expand("%", true)
      if (not string.sub(bufname, 1, 7) ~= "oil:///") then
        server.data.buffers[bufname] = bufnr
      end

      -- Create document/open event
      local event = require("docusync.server.events.constructor").events.document_open(bufname)

      -- Write the event to all connected clients
      for _, connection in pairs(server.connections) do
        connection:write(event, function(err) assert(not err, err) end)
      end
    end
  })

  -- Buffer DELETE listener
  vim.api.nvim_create_autocmd("BufDelete", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_delete", { clear = true }),
    pattern = "*",
    callback = function()
      local bufname = vim.fn.expand("%", true)
      server.data.buffers[bufname] = nil

      -- Create document/close event
      local event = require("docusync.server.events.constructor").events.document_close(bufname)

      -- Write the event to all connected clients
      for _, connection in pairs(server.connections) do
        connection:write(event, function(err) assert(not err, err) end)
      end
    end
  })

  -- Buffer ENTER listener
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_enter", { clear = true }),
    pattern = "*",
    callback = function()
      local bufname = vim.fn.expand("%", true)
      -- print("Server is now active in buffer: " .. bufname)
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
