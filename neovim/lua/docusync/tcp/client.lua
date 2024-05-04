-- Imports
local uv = vim.loop
local tcp_util = require("docusync.tcp.util")
local events = require("docusync.events")

-- tcp.client module
local M = {}

--- Connect to a tcp server and store the connection on the client object.
--- The client object should have a defined host and port otherwise this 
--- function will throw an error.
--- @param client Client The client to establish the connection onto
--- @param server Server The server data object from the main module  THIS IS TEMPORARY
--- @return nil
function M.connect(client, server)
  -- Create TCP objects on the connection field
  client.tcp = uv.new_tcp()

  -- Nil check on the tcp object
  assert(client.tcp, "Error creating TCP object")

  -- Attempt to connect
  client.tcp:connect(client.host, client.port, function (err)
    -- Check for errors
    assert(not err, err)

    -- Construct and send a server connect event
    vim.schedule(function()
      local event = events.constructor.events.server_connect(client.host, client.port, "Azpect", "")
      client.tcp:write(event, function (write_err) assert(not write_err, write_err) end)
    end)

    -- Read incoming data from the server
    tcp_util.connection_read_loop(client.tcp, function(read_err, chunk)
      -- Check for errors
      assert(not read_err, read_err)

      -- Print the data
      vim.schedule(function()
        if ((not events.parser.parse_event(chunk, client, server)) and (not events.parser.parse_notification(chunk)) and (not events.parser.parse_response(chunk))) then
          print("Failed to parse chunk: " .. "\"" .. chunk .. "\"")
        end
      end)
    end)
  end)

  -- Print success message
  print("Connected to server! (" .. client.host .. ":" .. client.port .. ")")
end

--- Disconnect from a tcp server and remove the connection from the client object.
--- The client object should have a defined tcp object otherwise this function will throw an error.
--- @param client Client The client to disconnect from a server
--- @return nil
function M.disconnect(client)
  -- Ensure the client has a tcp object
  assert(client.tcp, "Client is not connected to a server, cannot disconnect.")

  -- Close, shutdown and reset the connection
  -- Schedule is used to ensure the connection is killed at a valid time point in the event loop
  vim.schedule(function()
    client.tcp:close(function (err) assert(not err, err)end)
    client.tcp:shutdown(function(err) assert(not err, err) end)
    client.tcp = nil
  end)

  -- Print success message
  print("Disconnected from server! (" .. client.host .. ":" .. client.port .. ")")
end

-- Return module
return M
