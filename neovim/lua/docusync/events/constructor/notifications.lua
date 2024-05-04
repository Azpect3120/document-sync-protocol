return {
  --- Once the server has received the connection request, it will 
  --- emit a notification to all connected clients that a new client 
  --- has connected. The server will also send the new clients identifier 
  --- to all connected clients. Assuming the server implements the 
  --- capabilities for identifiers.
  ---
  --- This function will return an encoded notification to send to the clients.
  --- @param status boolean Whether the client connected successfully
  --- @param identifier string The identifier of the new client
  --- @param time number The time the client connected to the server
  --- @return string
  connect_to_server = function (status, identifier, time)
    local notification = vim.fn.json_encode({
      notification = "client/connect",
      status = status,
      identifier = identifier,
      time = time,
    })
    return notification
  end,
}
