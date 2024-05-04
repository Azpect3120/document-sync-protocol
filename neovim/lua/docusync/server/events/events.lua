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
        if identifier ~= event.identifier then
          connection:write(notification, function(write_err)
            if write_err then error("Error writing notification to client: " .. write_err) end
          end)
        end
      end

      -- Print error message on server and exit function
      error(err_msg)
    end

    -- TODO: Ensure the password match
    -- If they do not, generate an error response and send it to the client

    -- Add the new connection to the servers connection table
    server.connections[event.identifier] = client

    -- Send response to the client with the server details and its identifier
    local response = constructor.responses.server_connect(server, true, "", event.identifier)
    client:write(response, function(write_err)
      if write_err then
        error("Error writing response to client: " .. write_err)
      end
    end)

    -- Generate client/connect notification
    local notification = constructor.notifications.client_connect(true, event.identifier)

    -- Send the new client notification to all other clients
    for identifier, connection in pairs(server.connections) do
      if identifier ~= event.identifier then
        connection:write(notification, function(write_err)
          if write_err then error("Error writing notification to client: " .. write_err) end
        end)
      end
    end

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
  server_disconnect = function(server, event)
    -- Remove the client from the server's connection table
    server.connections[event.identifier] = nil

    -- Generate client/disconnect notification
    local notification = constructor.notifications.client_disconnect(event.identifier)

    -- Send the client/disconnect notification to all other clients on the server
    for _, connection in pairs(server.connections) do
      connection:write(notification, function(write_err)
        if write_err then error("Error writing notification to client: " .. write_err) end
      end)
    end

    -- Print success message on server
    print(event.identifier .. " has disconnected from the server!")
  end,
}
