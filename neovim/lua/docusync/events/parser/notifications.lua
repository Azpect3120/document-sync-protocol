return {
  --- Once the server has received the connection request, it will 
  --- emit a notification to all connected clients that a new client 
  --- has connected. The server will also send the new clients identifier 
  --- to all connected clients. Assuming the server implements the 
  --- capabilities for identifiers.
  ---
  --- @param notification string The notification to send to the clients.
  --- @return nil
  connect_to_server = function (notification)
    -- Decode the notification
    local decoded = vim.fn.json_decode(notification)

    -- Assert the notification was decoded
    assert(decoded, "Error decoding notification")

    -- Print message
    if (decoded.status) then
      print("Client " .. decoded.identifier .. " connected to the server at " .. decoded.time)
    else
      print("Client " .. decoded.identifier .. " failed to connect to the server")
    end
  end,
}
