--- Capabilities class
--- @class Capabilities
--- @field document_sync integer
--- @field compression string | nil
--- @field identifiers boolean
--- @field cursor_sync integer
--- @field client_count boolean

-- Module object
local M = {}

--- Default server capabilities
--- @return Capabilities
function M.default ()
    return {
        document_sync = 1000,
        compression = nil,
        identifiers = true,
        cursor_sync = 1000,
        client_count = true,
    }
end

--- Create a new Capabilities object
--- @param document_sync integer Time in milliseconds between syncs, 0 defines read-only for clients.
--- @param compression string | nil Should a compression algorithm be used, nil defines no compression. 
--- @param identifiers boolean Should the server support identifiers.
--- @param cursor_sync integer Time in milliseconds between cursor syncs, 0 defines no cursor sync.
--- @param client_count boolean Should the server send the client count to the clients.
--- @return Capabilities
function M.new(document_sync, compression, identifiers, cursor_sync, client_count)
    return {
        document_sync = document_sync,
        compression = compression,
        identifiers = identifiers,
        cursor_sync = cursor_sync,
        client_count = client_count,
    }
end

-- Return module object
return M