-- This file contains the callbacks for each server event that has been parsed

-- Imports
local events_util = require("docusync.server.events.util")
local constructor = require("docusync.server.events.constructor")

return {
  --- Ran by the user who wishes to connect to a running server.
  --- The callers files will remain unchanged until the connection
  --- is aborted. The client should connect to the server on the
  --- transport layer before emitting this event. The client is
  --- not considered connected until the server has received this
  --- connection event, regardless of the transport layer connection
  --- status.
  ---
  --- This function is responsible for handling the server/connect event.
  --- It will generate an identifier if one is not provided and ensure
  --- the host matches the server's host and port. If the host does not
  --- match, an error response will be generated and sent to the client.
  --- If the password does not match, an error response will be generated
  --- and sent to the client. If the host and password match, a success
  --- response will be generated and sent to the client. A client/connect
  --- notification will be generated and sent to all other clients on the
  --- server. The new client will be added to the server's connection table.
  --- @param server Server The server object
  --- @param event table The event data
  --- @param client uv_tcp_t The client connection object that was created
  --- @return nil
  server_connect = function(server, event, client)
    -- Generate an identifier if one is not provided
    if event.identifier == "" or not event.identifier then
      event.identifier = events_util.generete_identifer()
    end

    -- Ensure the host matches the server's host and port
    if event.host ~= (server.host .. ":" .. server.port) then
      local err_msg = "The host provided in the server/connect event does not match the server's host and port"
      -- Generate an error response
      local response = constructor.responses.server_connect(
        server,
        false,
        err_msg,
        event.identifier
      )

      -- Send the response to the client
      client:write(
        response,
        function(write_err)
          if write_err then
            error("Error writing response to client: " .. write_err)
          end
        end)

      -- Send failure notification to the clients on the server
      local notification = constructor.notifications.client_connect(false, event.identifier)

      -- Send the new client notification to all other clients
      for identifier, connection in pairs(server.connections) do
        if connection:is_active() then
          if identifier ~= event.identifier then
            connection:write(notification, function(write_err) assert(not write_err, write_err) end)
          else
            -- Update the connected clients window
            require("docusync.server.menu.edit").connected_clients(server)
            require("docusync.server.menu.edit").client_buffers(server)

            server.connections[connection] = nil
          end
        end
      end

      -- Print error message on server and exit function
      error(err_msg)
    end

    -- TODO: Ensure the password match
    -- If they do not, generate an error response and send it to the client

    -- Add the new connection to the servers connection table and the buffers table
    server.connections[event.identifier] = client
    server.data.client_buffers[event.identifier] = ""

    -- Send response to the client with the server details and its identifier
    local response = constructor.responses.server_connect(server, true, "", event.identifier)
    client:write(response, function(write_err) assert(not write_err, write_err) end)

    -- Generate client/connect notification
    local notification = constructor.notifications.client_connect(true, event.identifier)

    -- Send the new client notification to all other clients
    for identifier, connection in pairs(server.connections) do
      if connection:is_active() then
        if identifier ~= event.identifier then
          connection:write(notification, function(write_err) assert(not write_err, write_err) end)
        else
          -- Update the connected clients window
          require("docusync.server.menu.edit").connected_clients(server)
          require("docusync.server.menu.edit").client_buffers(server)

          server.connections[connection] = nil
        end
      end
    end

    -- Update the connected clients window
    require("docusync.server.menu.edit").connected_clients(server)
    require("docusync.server.menu.edit").client_buffers(server)

    -- Print success message on server
    print(event.identifier .. " has connected to the server!")
  end,

  --- Ran by the user who wishes to disconnect from the server. The callers
  --- files will remain unchanged until the connection is re-established.
  --- The connection is expected to be closed once this event is emitted,
  --- hence, no response is expected.
  ---
  --- This function is responsible for handling the server/disconnect event.
  --- It will remove the client from the server's connection table and send
  --- a client/disconnect notification to all other clients on the server.
  --- @param server Server The server object
  --- @param event table The event data
  --- @return nil
  server_disconnect = function(server, event)
    -- Remove the client from the server's connection table and the buffers table
    server.connections[event.identifier] = nil
    server.data.client_buffers[event.identifier] = nil

    -- Generate client/disconnect notification
    local notification = constructor.notifications.client_disconnect(event.identifier)

    -- Send the client/disconnect notification to all other clients on the server
    for _, connection in pairs(server.connections) do
      if connection:is_active() then
        connection:write(notification, function(write_err) assert(not write_err, write_err) end)
      else
        -- Update the connected clients window
        require("docusync.server.menu.edit").connected_clients(server)
        require("docusync.server.menu.edit").client_buffers(server)

        server.connections[connection] = nil
      end
    end

    -- Update the connected clients window
    require("docusync.server.menu.edit").connected_clients(server)
    require("docusync.server.menu.edit").client_buffers(server)

    -- Print success message on server
    print(event.identifier .. " has disconnected from the server!")
  end,

  --- The `document/list` event is emitted by any client who needs to get a list of the open documents on the server.
  --- The server will then send a list of the open documents to the client. The name of the document is the path of the document
  --- relative to the root in which Neovim was opened in.
  ---
  --- This function is responsible for handling the document/list event. It will send back a list of the open documents to the client.
  --- The documents can be found in the server.data.buffers table
  --- @param server Server The server object
  --- @param event table The event data
  --- @param client uv_tcp_t The client connection object that was created
  --- @return nil
  document_list = function(server, event, client)
    -- Create a list of the open documents
    local documents = {}
    for bufname, _ in pairs(server.data.buffers) do
      table.insert(documents, bufname)
    end

    -- Generate the document list response
    local response = constructor.responses.document_list(documents)

    -- Send the document list response to the client
    client:write(response, function(write_err)
      if write_err then error("Error writing response to client: " .. write_err) end
    end)
  end,

  --- The `document/open` event is emitted by the client whenever a document is opened by the client. The server will then
  --- send back the content of the document to the client. The name of the document is the path of the document relative to
  --- the root in which Neovim was opened in. The content will be sent back to the client in a line-by-line format.
  ---
  --- This function is responsible for handling the document/open event. It will send back the content of the document to the client.
  --- The content of the document is sent back in a line-by-line format. This function will also update the server's data with the
  --- client's connection to the document and update the menu windows.
  --- @param server Server The server object
  --- @param event table The event data
  --- @param client uv_tcp_t The client connection object that was created
  --- @return nil
  document_open = function(server, event, client)
    -- Ensure the document exists in the server's data
    if not server.data.buffers[event.document] then
      local response = constructor.responses.document_open(
        false,
        "Document has been opened by the server or does not exist!",
        event.document,
        {}
      )

      -- Send errored response to the client
      client:write(response, function(write_err)
        if write_err then error("Error writing response to client: " .. write_err) end
      end)
      return
    end

    -- Add the clients connection to buffer table
    server.data.client_buffers[event.identifier] = event.document

    -- Update menu windows
    require("docusync.server.menu.edit").client_buffers(server)

    -- Get the content of the document
    local bufs = vim.api.nvim_list_bufs()
    for _, bufnr in pairs(bufs) do
      -- Get the relative buffer name
      local bufname_long = vim.api.nvim_buf_get_name(bufnr)
      local cwd = vim.loop.cwd()
      local bufname = string.sub(bufname_long, #cwd + 2, #bufname_long)

      -- Find the right buffer
      if event.document == bufname then
        -- Get the content of the buffer
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        -- Construct the response
        local response = constructor.responses.document_open(true, "", event.document, lines)

        -- Send the response to the client
        client:write(response, function(write_err)
          if write_err then error("Error writing response to client: " .. write_err) end
        end)

        break
      end
    end
  end,

  --- The `document/close` event is emitted by the client whenever a document is closed by the client. The server will then
  --- update the data stored in the server and handle any other necessary actions. The name of the document is the path of
  --- the document relative to the root in which Neovim was opened in.
  ---
  --- This function is responsible for handling the document/close event. It will update the server's data with the client's
  --- disconnection from the document and update the menu windows.
  --- @param server Server The server object
  --- @param event table The event data
  --- @param client uv_tcp_t The client connection object that was created
  document_close = function(server, event, client)
    -- Ensure the document exists in the server's data
    if not server.data.buffers[event.document] then
      local response = constructor.responses.document_open(
        false,
        "Document has been opened by the server or does not exist!",
        event.document,
        {}
      )

      -- Send errored response to the client
      client:write(response, function(write_err)
        if write_err then error("Error writing response to client: " .. write_err) end
      end)
      return
    end

    -- Remove the clients connection to buffer table
    server.data.client_buffers[event.identifier] = ""

    -- Update menu windows
    require("docusync.server.menu.edit").client_buffers(server)
  end,
  --- The `document/update` event is emitted by the client whenever a client updates the document.
  --- The exact action that is required before emitting this event can vary depending on the client implementation.
  --- But the client should send the entire document content to the server when emitting this event. The server will
  --- then handle this data by ["diffing"](https://neovim.io/doc/user/lua.html#vim.diff) each line and updating the
  --- servers page with the new content. The server will then emit the `document/sync` event to all connected clients,
  --- which works basically the same way but with the roles reversed.
  ---
  --- This function is responsible for handling the document/update event. It will update the content of the document
  --- on the server using the provided content. It will then send a document/sync event to all connected clients.
  --- The content is swapped using a diffing method.
  --- @param server Server The server object
  --- @param event table The event data
  --- @param client uv_tcp_t The client connection object that was created
  --- @return nil
  document_update = function(server, event, client)
    -- Ensure the document exists in the server's data
    if not server.data.buffers[event.document] then
      -- Generate some kind of error response here
      -- Or maybe just do nothing?
      return print(event.document .. " does not exist in the server's data")
    end

    -- Schedule the update to happen in the next safe tick
    vim.schedule(function()
      -- Get the buffer number of the document on the server
      local bufnr = server.data.buffers[event.document]

      -- Get the current content of the server's version of the document
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      -- Diff the content of the document and update it on the server
      for i, line in ipairs(event.content) do
        if lines[i] ~= line then
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { line })
          end)
        elseif lines[i] == nil then
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { "" })
          end)
        end
      end

      -- If lines were removed, clear them from the end of the file
      -- BRILLIANT FIX RIGHT HERE
      if #event.content < #lines then
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, #event.content, -1, false, {})
        end)
      end

      -- Get the new lines of the document
      lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      -- Generate the document sync event
      local sync_event = constructor.events.document_sync(event.document, lines)

      -- Send the document sync event to all connected clients
      for identifier, connection in pairs(server.connections) do
        if connection:is_active() then
          if identifier ~= event.identifier then
            connection:write(sync_event, function(write_err) assert(not write_err, write_err) end)
          end
        else
          -- Update the connected clients window
          require("docusync.server.menu.edit").connected_clients(server)
          require("docusync.server.menu.edit").client_buffers(server)

          server.connections[connection] = nil
        end
      end
    end)
  end,
}
