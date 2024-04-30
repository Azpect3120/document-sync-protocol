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

--- Parse the document/update event being sent from the server.
--- @param data string
--- @param capabilities Capabilities
function M.document_update (data, capabilities)
  -- Check if document sync is supported
  assert(capabilities.document_sync, "Document sync is not supported")

  print("Document update event is being parsed!")
  local event = vim.fn.json_decode(data)

  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, event.content)
  local winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winnr, bufnr)

end


return M
