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

  --- The `document/open` notification is emitted by the server whenever a new document is opened. The server will then allow
  --- the clients to connect to the document and begin syncing the document content. The `document/list` event can be used
  --- to get a list of the all the documents that are currently open on the server. The name of the document is the path
  --- of the document relative to the root in which Neovim was opened in. The content that is in the document will be sent
  --- to the client when they connect to the document.
  ---
  --- This function is responsible for handling the document/open event. It will alert the client that a new document has
  --- been opened. FOR NOW THAT IS IT!
  --- @param event table The event object that was parsed
  --- @param client Client The client object
  --- @return nil
  document_open = function(event, client)
    local _ = client
    print("A new document was opened: " .. event.document)
  end,

  --- The `document/close` notification is emitted by the server whenever a new document is closed. The server will then stop
  --- any connections to the document and the clients will no longer be able to connect to the document. The `document/list`
  --- event can be used to get a list of the all the documents that are currently open on the server. The name of the document
  --- is the path of the document relative to the root in which Neovim was opened in.
  --- 
  --- This function is responsible for handling the document/close event. It will alert the client that a document has
  --- been closed. FOR NOW THAT IS IT!
  --- @param event table The event object that was parsed
  --- @param client Client The client object
  --- @return nil
  document_close = function(event, client)
    local _ = client
    print("A document was closed: " .. event.document)
  end,
}
