-- Import capabilities class
require("docusync.capabilities")

return {
  --- This response will be sent to only the client who emitted the ConnectServerEvent.
  --- The NewClientConnectionNotification will be emitted to all connected clients.
  ---
  --- This function will return an encoded response to send to the client.
  --- @param success boolean Whether the connection was successful
  --- @param error string The error message if the connection was not successful
  --- @param identifier string The identifier of the client, if the client did not provide one, it will be random and unique
  --- @param capabilities Capabilities The capabilities of the server
  --- @return string
  connect_to_server = function (success, error, identifier, capabilities)
    local response = vim.fn.json_encode({
      response = "server/connect",
      success = success,
      error = error,
      identifier = identifier,
      capabilities = capabilities,
    })
    return response
  end,
}
