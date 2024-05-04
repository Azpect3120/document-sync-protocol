-- This file contains all the constructors for the client sent events, responses and notifications.

return {
  events = {
    --- Ran by the user who wishes to connect to a running server. The callers 
    --- files will remain unchanged until the connection is aborted. The client 
    --- should connect to the server on the transport layer before emitting this 
    --- event. The client is not considered connected until the server has 
    --- received this connection event, regardless of the transport layer 
    --- connection status.
    --- 
    --- This function will construct a server/connect event which the client will
    --- send to the server when the transport layer connection is established.
    --- @param host string The host of the server to connect to
    --- @param port number The port of the server to connect to
    --- @param identifier string The identifier of the client, if blank the server will provide a unique one
    --- @param password string The password of the server, if the server does not require a password this can be blank
    --- @return string
    server_connect = function(host, port, identifier, password)
      local event = vim.fn.json_encode({
        event = "server/connect",
        host = host .. ":" .. port,
        identifier = identifier,
        password = password,
      })
      return event
    end,
  },
  responses = {},
  notifications = {},
}
