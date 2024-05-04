-- Imports
local constructor = require("docusync.events.constructor")

return {
  --- Ran by the user who wishes to connect to a running server. 
  --- The callers files will remain unchanged until the connection is aborted.
  --- The client should connect to the server on the transport layer before 
  --- emitting this event. The client is not considered connected until the 
  --- server has received this connection event, regardless of the transport 
  --- layer connection status.
  --- @param event string The encoded event to parse
  --- @pararm client Client The client object
  --- @param server Server The server object
  --- @return nil
  server_connect = function (event, client, server)
    -- Decode the event
    local decoded = vim.fn.json_decode(event)

    -- Assert that the event was decoded
    assert(decoded, "Failed to decode event")

    -- Print the identifier of the connected client
    print(decoded.identifier .. " connected to the server!")

    -- Emit the response event to the client
    local response = constructor.responses.connect_to_server(true, "", decoded.identifier, server.capabilities)
    client.tcp:write(response, function (err) assert(not err, err) end)

    -- Emit the notification event to ALL clients
    local notification = constructor.notifications.connect_to_server(true, decoded.identifier, os.time())
    for _, connection in pairs(server.connections) do
      connection.tcp:write(notification, function (err) assert(not err, err) end)
    end
  end,

  --- Ran by the user who wishes to disconnect from the server.
  --- The callers files will remain unchanged until the connection is 
  --- re-established. The connection is expected to be closed once this 
  --- event is emitted, hence, no response is expected.
  --- @param event string The encoded event to parse
  --- @return nil
  server_disconnect = function (event)
    -- Decode the event
    local decoded = vim.fn.json_decode(event)

    print(vim.inspect(decoded))
  end,

  document_sync = function (event)
    -- Decode the event
    local decoded = vim.fn.json_decode(event)

    print(vim.inspect(decoded))
  end,

  document_update = function (event)
    -- Decode the event
    local decoded = vim.fn.json_decode(event)

    print(vim.inspect(decoded))
  end,
}
