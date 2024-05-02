--- Imports
local parser = require("docusync.parser.parser")

--- Capabilities class
--- @class Capabilities
--- @field document_sync integer
--- @field compression string | nil
--- @field identifiers boolean
--- @field cursor_sync integer
--- @field client_count boolean

--- Sync document event class
--- @class E_SyncDocument
--- @field event string = "document/sync"
--- @field partial boolean
--- @field content string
--- @field document string
--- @field location integer | nil  -- This has not been constructed in my head yet
--- @field time integer

--- Event parser class
--- @class Events
--- @field capabilities Capabilities
local M = {
  -- Default server capabilities (FIX: Decide what values to use)
  capabilities = {
    document_sync = 1000,
    compression = nil,
    identifiers = true,
    cursor_sync = 1000,
    client_count = true,
  },
}

--- Parse events data
--- @param server Server
--- @param data string
function M.parse(server, data)
  -- Parse out the event type
  -- Ignore the field issue :(
  local event = vim.fn.json_decode(data).event
  assert(event, "Failed to parse event: Could not parse event type (#1)")

  -- Switch the event based on the type
  -- The entire data string is passed into the helper functions
  if event == "document/sync" then
    parser.document_sync(data, M.capabilities)
  elseif event == "document/update" then
    parser.document_update(server, data, M.capabilities)
  else
    print("Unknown event: " .. event)
  end

end

--- Construct sync document event.
--- Called by the server to construct a sync document event to be sent to the client.
--- @param partial boolean Is the content a partial or full document
--- @param content table<string> The document content as lines
--- @param document string The document name
--- @param location table<integer> Should have to integers [ start_line, end_line ], it not a partial, use a blank table
--- @param time integer The time the event was created
--- @return string event The constructed event
function M.construct_sync_document(partial, content, document, location, time)
  -- Check if document sync is supported
  assert(M.capabilities.document_sync > 0, "Document sync is not supported")

  -- TODO: Figure out how to use partial and location. That will be based on how I implement the neovim client 

  -- Construct event
  -- TODO: Determine if I want to use json or nothing else
  local event = vim.fn.json_encode({
    event = "document/sync",
    partial = partial,
    content = content,
    document = document,
    location = location,
    time = time,
  })

  return event
end

--- Construct update document event.
--- Called by the client to construct an update document event to be sent to the server.
--- @param partial boolean Is the content a partial or full document
--- @param identifier string The client identifier:w
--- @param content table<string> The document content as lines
--- @param document string The document name
--- @param location table<integer> Should have to integers [ start_line, end_line ], it not a partial, use a blank table
--- @param time integer The time the event was created
--- @return string event The constructed event
function M.construct_update_document(partial, identifier, content, document, location, time)
  -- Check if document sync is supported
  assert(M.capabilities.document_sync > 0, "Document sync is not supported")

  -- TODO: Figure out how to use partial and location. That will be based on how I implement the neovim client 

  -- Construct event
  -- TODO: Determine if I want to use json or nothing else
  local event = vim.fn.json_encode({
    event = "document/update",
    identifier = identifier,
    partial = partial,
    content = content,
    document = document,
    location = location,
    time = time,
  })

  return event
end

-- Return parser
return M
