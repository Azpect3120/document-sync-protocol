-- This file contains all the constructors for the server sent events, responses and notifications.

return {
  events = {},

  responses = {
    --- This response will be sent to only the client who emitted the ConnectServerEvent.
    --- The NewClientConnectionNotification will be emitted to all connected clients.
    ---
    --- This function will generate a ConnectServerResponse object and return it as a
    --- JSON encoded string which is emitted to the client that has connected to the server.
    --- @param server Server
    --- @param success boolean
    --- @param error string
    --- @param identifier string
    --- @return string
    server_connect = function(server, success, error, identifier)
      local response = vim.fn.json_encode({
        response = "server/connect",
        success = success,
        error = error,
        identifier = identifier,
        capabilities = server.capabilities,
      })
      return response
    end
  },

  notifications = {
    --- Once the server has received the connection request, it will emit a notification
    --- to all connected clients that a new client has connected. The server will also
    --- send the new clients identifier to all connected clients. Assuming the server
    --- implements the capabilities for identifiers.
    ---
    --- This function will generate a NewClientConnectionNotification object and return
    --- it as a JSON encoded string which is emitted to all connected clients, expect
    --- the new client that has connected to the server.
    --- @param status boolean The status of the new connection
    --- @param identifier string The identifier of the new client
    --- @return string
    client_connect = function(status, identifier)
      local notification = vim.fn.json_encode({
        notification = "client/connect",
        status = status,
        identifier = identifier,
        time = os.time()
      })
      return notification
    end,

    --- Once the server has received the connection request, it will emit a notification
    --- to all connected clients that a new client has connected. The server will also
    --- send the new clients identifier to all connected clients. Assuming the server
    --- implements the capabilities for identifiers.
    ---
    --- This function will generate a NewClientDisconnectionNotification object and return
    --- it as a JSON encoded string which is emitted to all connected clients, expect
    --- the client that has disconnected from the server.
    --- @param identifier string The identifier of the client that has disconnected
    client_disconnect = function(identifier)
      local notification = vim.fn.json_encode({
        notification = "client/disconnect",
        identifier = identifier,
        time = os.time()
      })
      return notification
    end,
  },
}
