-- client/buffers.lua module
local M = {}


--- Begin the buffer handling for the client. This include setting up the
--- watcher to add buffers to the server. This function will setup autocommands
--- to listen for buffer events. This function should also include any events
--- being sent to the clients to notify them of the buffer changes.
--- @param client Client The server object to attach to.
--- @return nil
function M.listen (client)
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("DocuSyncBufferListener_enter", { clear = true }),
    pattern = "docusync:///*",
    callback = function (event)
      -- Will get the name of the document without the 'docusync:///' prefix
      local document = string.sub(event.file, 13)

      -- Construct the document/open event to send from the client
      local event = require("docusync.client.events.constructor").events.document_open(client.server_details.identifier, document)

      -- Send the event to the server
      client.tcp:write(event, function(err) assert(not err, err) end)
    end
  })
end

return M
