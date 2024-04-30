--- Main parse module
local M = {}

--- Parse the document/sync event.
--- @param data string
--- @param capabilities Capabilities
function M.document_sync (data, capabilities)
  -- Check if document sync is supported
  assert(capabilities.document_sync, "Document sync is not supported")

  print("Document sync event is being parsed!")
  local parsed = vim.fn.json_decode(data)
  print(vim.inspect(parsed or {}))
end


return M
