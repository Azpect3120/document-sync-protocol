--- Imports
local util = require("docusync.util")
local strings = util.strings
local parser = require("docusync.parser.parser")

--- Capabilities class
--- @class Capabilities
--- @field document_sync integer
--- @field compression string | nil
--- @field indentifiers boolean
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
    indentifiers = true,
    cursor_sync = 1000,
    client_count = true,
  },
}

--- Parse events data
--- @param data string
function M.parse(data)
  -- Parse out the event type
  -- Ignore the field issue :(
  local event = vim.fn.json_decode(data).event
  assert(event, "Failed to parse event: Could not parse event type (#1)")

  -- Switch the event based on the type
  -- The entire data string is passed into the helper functions
  if event == "document/sync" then
    parser.document_sync(data, M.capabilities)
  else
    print("Unknown event: " .. event)
  end

end

--- Construct sync document event.
--- Called by the client to construct a sync document event to be sent to the server.
--- Params:
---  - partial: is the content a partial or full document
---  - content: the content to sync
---  - document: the document to sync (name)
---  - location: the location to sync (only for use with partials)
---  - time: the time this event was created
--- Returns:
---  - the constructed sync document event to send to the server
--- @param partial boolean
--- @param content string
--- @param document string
--- @param location integer | nil
--- @param time integer
--- @return string
function M.construct_sync_document(partial, content, document, location, time)
  -- Check if document sync is supported
  assert(M.capabilities.document_sync > 0, "Document sync is not supported")

  -- TODO: Figure out how to use partial and location. That will be based on how I implement the neovim client 

  -- Construct event
  -- TODO: Determine if I want to use json or nothing else
  local event = "{" .. table.concat({
    "\"event\": \"document/sync\"",
    "\"partial\": " .. "\"".. tostring(partial) .. "\"",
    "\"content\": " .. "\"".. content .. "\"",
    "\"document\": " .. "\"".. document .. "\"",
    "\"location\": " .. (location or 0),      -- Again, not sure what this is for or how to use it yet
    "\"time\": " .. time,
  }, ", ") .. "}"

  return event
end


-- Return parser
return M
