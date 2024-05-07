-- Imports
local uv = vim.loop
local tcp_util = require("docusync.tcp.util")

-- tcp.server module
local M = {}

--- Start a tcp server that will listen for incoming connections.
--- The server object will be stored on the server object.
--- @param server Server The server object to start.
--- @return nil
function M.start_server(server)
  -- Nil check on the tcp object
  assert(server.tcp == nil, "Server is already running, Stop first.")

  -- Ensure capabilities exist
  server.capabilities = server.capabilities or require("docusync.capabilities").default()

  -- Create the tcp server
  server.tcp = uv.new_tcp()

  -- Bind the server to the host:port and handle error
  local success, error = server.tcp:bind(server.host, server.port)
  assert(success, error)

  -- Start the listener that will handler the buffers in the server
  require("docusync.server.buffers").listen(server)

  -- Listen for connections
  server.tcp:listen(128, function(err)
    -- Check for errors
    assert(not err, err)

    -- Accept client connections
    local client = uv.new_tcp()
    server.tcp:accept(client)
    assert(client, "Failed to accept client connection")

    -- Print the successful connection from a client
    print("Accepted connection(TCP) from " .. client:getpeername().ip .. ":" .. client:getpeername().port)

    -- Read incoming data from the client
    tcp_util.connection_read_loop(client, function(read_err, chunk)
      -- Check for errors
      assert(not read_err, read_err)

      -- Parse the event/notification
      vim.schedule(function()
        require("docusync.server.events").parser.parse(server, chunk, client)
      end)
    end)
  end)

  -- Print the server has been started
  print("Server has been started on " .. server.host .. ":" .. server.port)
end

--- Stop a tcp server that is currently running.
--- This will close all connections and stop the server.
--- @param server Server The server object to stop.
--- @return nil
function M.stop_server(server)
  -- Nil check on the tcp object
  assert(server.tcp, "Server is not running, cannot stop.")

  -- Generate a server/stop event
  local event = require("docusync.server.events.constructor").events.server_stop(server.host, server.port)

  -- Write the event to all connected clients and disconnect any inactive connections
  for _, connection in pairs(server.connections) do
    if connection:is_active() then
      connection:write(event, function(err) assert(not err, err) end)
    else
      server.connections[connection] = nil
    end
  end

  -- Shutdown/close the server and handle errors
  -- Schedule is used to ensure the server is killed at a valid time point in the event loop
  vim.schedule(function()
    server.tcp:shutdown(function(err) assert(not err, err) end)
    server.tcp:close(function(err) assert(not err, err) end)
    server.tcp = nil
  end)

  -- Reset the connections table
  server.connections = {}
  server.capabilities = nil
  server.data = { buffers = {} }

  -- Print the server has been stopped
  print("Server has been stopped.")
end

-- Return module
return M
