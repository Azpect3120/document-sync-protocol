--- Imports
local util = require("docusync.util")
local strings = util.strings

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
  -- Yes this is messy, and yes it works, and yes I will clean it up later
  local event = strings.split(strings.split(data:sub(2, -2), ",")[1], ":")[2]

  print(event)

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
