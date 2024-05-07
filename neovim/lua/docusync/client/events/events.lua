-- This file contains the callbacks for each client event that has been parsed

return {
  --- Ran by the user who wishes to disconnect from the server. The callers
  --- files will remain unchanged until the connection is re-established. The
  --- connection is expected to be closed once this event is emitted, hence,
  --- no response is expected.
  ---
  --- This function is responsible for handling the server/disconnect event.
  --- It will close the clients connection as well as inform them of the server
  --- being closed. With this event, the client does NOT need to emit the
  --- client/disconnect event.
  --- @param event table The event object that was parsed
  --- @param client Client The client object
  --- @return nil
  server_stop = function(event, client)
    -- Notify the client that the server is stopping
    print("Server has been stopped by host " .. event.host)

    -- Close the clients TCP connection
    vim.schedule(function()
      client.tcp:close(function(err) assert(not err, err) end)
      client.tcp:shutdown(function(err) assert(not err, err) end)

      -- Null the client object fields
      client.tcp = nil
      client.server_details.identifier = ""
      client.server_details.capabilities = nil
    end)
  end,

  --- The `document/open` event is emitted by the server whenever a new document is opened. The server will then allow
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

  --- The `document/close` event is emitted by the server whenever a new document is closed. The server will then stop
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
