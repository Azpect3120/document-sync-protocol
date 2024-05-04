-- This file contains the callbacks for each client notification that has been parsed

return {
  --- Once the server has received the connection request, it will emit 
  --- a notification to all connected clients that a new client has connected. 
  --- The server will also send the new clients identifier to all connected 
  --- clients. Assuming the server implements the capabilities for identifiers.
  ---
  --- This function doesn't really do all that much, just print a message on the
  --- client's side that a new client has connected.
  --- @param notification table The notification data.
  --- @return nil
  client_connect = function(notification)
    if not notification.status then
      return print("A client failed to connect!")
    else
      return print(notification.identifier .. " has connected!")
    end
  end,

  --- Once the server has received the connection request, it will emit a 
  --- notification to all connected clients that a new client has connected. 
  --- The server will also send the new clients identifier to all connected 
  --- clients. Assuming the server implements the capabilities for identifiers.
  ---
  --- This function doesn't really do all that much, just print a message on the
  --- client's side that a new client has disconnected.
  --- @param notification table The notification data.
  --- @return nil
  client_disconnect = function(notification)
    return print(notification.identifier .. " has disconnected!")
  end,
}
