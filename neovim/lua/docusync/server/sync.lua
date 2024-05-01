-- Imports
local events = require("docusync.parser.events")

-- Main update module
local M = {}

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
  local timeout = 5000

  -- Schedule interval to start
  timer:start(0, timeout, vim.schedule_wrap(function ()
    -- Construct the sync event without partial content
    local event = events.construct_sync_document(
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
  end))

  -- Return the timer
  return timer
end


return M
