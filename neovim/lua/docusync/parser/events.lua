--- Imports
local parser = require("docusync.parser.parser")

--- Sync document event class
--- @class E_SyncDocument
--- @field event string = "document/sync"
--- @field partial boolean
--- @field content string
--- @field document string
--- @field location integer | nil  -- This has not been constructed in my head yet
--- @field time integer

--- Event parser object
local M = {}

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
    parser.document_sync(data, server.capabilities)
  elseif event == "document/update" then
    parser.document_update(server, data, server.capabilities)
  else
    print("Unknown event: " .. event)
  end

end

--- Construct sync document event.
--- Called by the server to construct a sync document event to be sent to the client.
--- @param server Server The server object
--- @param partial boolean Is the content a partial or full document
--- @param content table<string> The document content as lines
--- @param document string The document name
--- @param location table<integer> Should have to integers [ start_line, end_line ], it not a partial, use a blank table
--- @param time integer The time the event was created
--- @return string event The constructed event
function M.construct_sync_document(server, partial, content, document, location, time)
  -- Check if document sync is supported
  assert(server.capabilities.document_sync > 0, "Document sync is not supported")

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
--- @param server Server The server object
--- @param partial boolean Is the content a partial or full document
--- @param identifier string The client identifier:w
--- @param content table<string> The document content as lines
--- @param document string The document name
--- @param location table<integer> Should have to integers [ start_line, end_line ], it not a partial, use a blank table
--- @param time integer The time the event was created
--- @return string event The constructed event
function M.construct_update_document(server, partial, identifier, content, document, location, time)
  -- Check if document sync is supported
  assert(server.capabilities.document_sync > 0, "Document sync is not supported")

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

--- Construct server disconnect event.
--- Called by the client before disconnecting to inform the server that a client has disconnected.
--- @param identifier string The client's unique identifier
--- @param host string The server host that the client is disconnecting from, must include port (host:port)
--- @return string event The constructed event
function M.construct_server_disconnect(identifier, host)
  -- Construct event
  -- TODO: Determine if I want to use json or nothing else
  local event = vim.fn.json_encode({
    event = "server/disconnect",
    identifier = identifier,
    host = host,
  })

  return event
end

-- Return parser
return M
