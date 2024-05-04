return {
  --- Ran by the user who wishes to connect to a running server. 
  --- The callers files will remain unchanged until the connection is aborted.
  --- The client should connect to the server on the transport layer before 
  --- emitting this event. The client is not considered connected until the 
  --- server has received this connection event, regardless of the transport 
  --- layer connection status.
  ---
  --- This function will return an encoded event to send to the server.
  --- @param host string The host to connect to
  --- @param port number The port to connect to
  --- @param identifier string The identifier to use for the connection, "" for no identifier
  --- @param password string The password to use for the connection, "" for no password
  --- @return string
  server_connect = function (host, port, identifier, password)
    local event = vim.fn.json_encode({
      event = "server/connect",
      host = host .. ":" .. port,
      identifier = identifier,
      password = password,
    })
    return event
  end,

  server_disconnect = function () end,

  document_sync = function () end,

  document_update = function () end,
}
