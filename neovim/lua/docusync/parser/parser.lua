--- Main parse module
local M = {}

--- Parse the document/sync event being sent from the server.
--- @param data string
--- @param capabilities Capabilities
function M.document_sync(data, capabilities)
  -- Check if document sync is supported
  assert(capabilities.document_sync, "Document sync is not supported")

  local event = vim.fn.json_decode(data)
  print(vim.inspect(event))

  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if (name == event.document) then
      if (event.partial) then
        assert(event.location, "Partial document sync requires a location")
        vim.api.nvim_buf_set_lines(bufnr, event.location[1], event.location[2], false, event.content)
      else
        -- Get the users mode, and wait until they are in normal mode to update the buffer
        local mode = vim.api.nvim_get_mode().mode

        if mode ~= "i" then
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, event.content)
        else
          -- Execute the autocmd
          -- This seems to leak the auto command but honestly, idfk
          vim.api.nvim_command("autocmd InsertLeave <buffer> lua vim.api.nvim_buf_set_lines(" ..
          bufnr .. ", 0, -1, false, " .. vim.inspect(event.content) .. ")")
        end
      end
    end
  end
end

--- Parse the document/update event being sent to the server.
--- @param server Server
--- @param data string
--- @param capabilities Capabilities
function M.document_update(server, data, capabilities)
  -- Check if document sync is supported
  assert(capabilities.document_sync, "Document sync is not supported")
  assert(server, "Server is not defined")

  -- Decode the event
  local event = vim.fn.json_decode(data)
  print(vim.inspect(event))

  -- Find the buffer number
  -- TODO: This is a temporary solution, need to find a better way to do this
  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if (name == event.document) then
      if (event.partial) then
        assert(event.location, "Partial document sync requires a location")
        vim.api.nvim_buf_set_lines(bufnr, event.location[1], event.location[2], false, event.content)
      else
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, event.content)
      end
    end
  end

  -- Update the server flag
  server.f_update = true
end

return M

--   Error executing vim.schedule lua callback: ...cumentSyncProtocol/neovim/lua/docu
-- usync/parser/parser.lua:54: attempt to index local 'server' (a nil value)
-- stack traceback:
-- ...cumentSyncProtocol/neovim/lua/docusync/parser/parser.lua:54: in function 'do
-- ocument_update'
-- ...cumentSyncProtocol/neovim/lua/docusync/parser/events.lua:49: in function 'pa
-- arse'
-- ...rojects/DocumentSyncProtocol/neovim/lua/docusync/tcp.lua:52: in function <..
-- ..rojects/DocumentSyncProtocol/neovim/lua/docusync/tcp.lua:51>
