--- Main parse module
local M = {}

--- Parse the document/sync event being sent from the server.
--- @param data string
--- @param capabilities Capabilities
function M.document_sync (data, capabilities)
  -- Check if document sync is supported
  assert(capabilities.document_sync, "Document sync is not supported")

  print("Document sync event is being parsed!")
  local _ = vim.fn.json_decode(data)
end

--- Parse the document/update event being sent to the server.
--- @param data string
--- @param capabilities Capabilities
function M.document_update (data, capabilities)
  -- Check if document sync is supported
  assert(capabilities.document_sync, "Document sync is not supported")

  -- Decode the event
  local event = vim.fn.json_decode(data)

  -- Find the buffer number
  -- TODO: This is a temporary solution, need to find a better way to do this
  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    if (name == event.document) then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, event.content)
    end
  end
end


return M
