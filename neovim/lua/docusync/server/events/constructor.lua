-- This file contains all the constructors for the server sent events, responses and notifications.

return {
  events = {
    --- Ran by the user who wishes to stop their running server. The server will no longer
    --- accept connections and the connected clients will be disconnected. Any data that
    --- was not synced will be lost.
    ---
    --- This function will generate a server/stop event and return it as a JSON encoded string
    --- which is emitted by the server to all connected clients before the server stops.
    --- @param host string The host of the server
    --- @param port number The port of the server
    --- @return string
    server_stop = function(host, port)
      local event = vim.fn.json_encode({
        event = "server/stop",
        host = host .. ":" .. port,
        time = os.time()
      })
      return event
    end,

  },

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
    end,

    --- This is the response returned by the server a client emits the `document/list` event.
    ---
    --- This function will generate a DocumentListResponse object and return it as a JSON encoded string
    --- @param documents table<string> The list of open documents
    --- @return string
    document_list = function(documents)
      local response = vim.fn.json_encode({
        response = "document/list",
        documents = documents,
        status = true,
        time = os.time()
      })
      return response
    end,

    --- The `document/open` response is emitted by the server whenever a client opens a document. The server will then send the
    --- content of the document to the client. The name of the document is the path of the document relative to the root in which
    --- Neovim was opened in. The content will be sent back to the client in a line-by-line format. This response is only sent to
    --- the client who emitted the `document/open` event.
    --
    --- This function will generate a DocumentOpenResponse object and return it as a JSON encoded string
    --- @param status boolean The status of the document open request
    --- @param error string The error message if the document open request failed
    --- @param document string The name of the document
    --- @param content table<string> The content of the document
    --- @return string
    document_open = function(status, error, document, content)
      local response = vim.fn.json_encode({
        response = "document/open",
        status = status,
        error = error,
        document = document,
        content = content,
        time = os.time()
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

    --- The `document/open` notification is emitted by the server whenever a new document is opened. The server will then allow
    --- the clients to connect to the document and begin syncing the document content. The `document/list` event can be used
    --- to get a list of the all the documents that are currently open on the server. The name of the document is the path
    --- of the document relative to the root in which Neovim was opened in. The content that is in the document will be sent
    --- to the client when they connect to the document.
    ---
    --- This function will generate a document/open event and return it as a JSON encoded string which is emitted by the server
    --- @param document string The path of the document that was opened
    --- @return string
    document_open = function(document)
      local event = vim.fn.json_encode({
        notification = "document/open",
        document = document,
        time = os.time()
      })
      return event
    end,

    --- The `document/close` notification is emitted by the server whenever a new document is closed. The server will then stop
    --- any connections to the document and the clients will no longer be able to connect to the document. The `document/list`
    --- event can be used to get a list of the all the documents that are currently open on the server. The name of the document
    --- is the path of the document relative to the root in which Neovim was opened in.
    ---
    --- This function will generate a document/close event and return it as a JSON encoded string which is emitted by the server
    --- @param document string The path of the document that was closed
    --- @return string
    document_close = function(document)
      local event = vim.fn.json_encode({
        notification = "document/close",
        document = document,
        time = os.time()
      })
      return event
    end,

  },
}
