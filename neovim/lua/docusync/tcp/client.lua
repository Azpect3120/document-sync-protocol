-- Imports
local uv = vim.loop
local tcp_util = require("docusync.tcp.util")

-- tcp.client module
local M = {}

--- Connect to a tcp server and store the connection on the client object.
--- The client object should have a defined host and port otherwise this
--- function will throw an error.
--- @param client Client The client to establish the connection onto
--- @return nil
function M.connect(client)
  -- Create TCP objects on the connection field
  client.tcp = uv.new_tcp()

  -- Nil check on the tcp object
  if client.tcp == nil then
    error("Error creating TCP object")
  end

  -- Attempt to connect
  client.tcp:connect(client.host, client.port, function(err)
    -- Check for errors
    if err then
      client.tcp = nil
      error(err)
    end

    -- Start the client buffer listener
    vim.schedule(function()
      require("docusync.client.buffers").listen(client)
    end)

    -- Construct and send a server/connect event
    vim.schedule(function()
      -- Construct event
      local event = require("docusync.client.events.constructor").events.server_connect(
        client.host,
        client.port,
        client.server_details.identifier,
        client.server_details.password
      )

      -- Send event to server
      if client.tcp:is_active() then
        client.tcp:write(event, function(write_err)
          assert(not write_err, write_err)
        end)
      else
        error("Failed to send event to server, connection is not active.")
      end
    end)

    -- Read incoming data from the server
    tcp_util.connection_read_loop(client.tcp, function(read_err, chunk)
      -- Check for errors
      assert(not read_err, read_err)

      -- Parse the event/notification
      vim.schedule(function()
        require("docusync.client.events").parser.parse(client, chunk)
      end)
    end)
  end)

  -- Create auto-command for client end when vim is exited
  vim.api.nvim_create_autocmd({"VimLeavePre", "QuitPre"}, {
    once = true,
    pattern = "*",
    callback = function()
      local event = require("docusync.client.events.constructor").events.server_disconnect(client.host, client.port, client.server_details.identifier)
      client.tcp:write(event, function(err) assert(not err, err) end)
    end,
  })
end

--- Disconnect from a tcp server and remove the connection from the client object.
--- The client object should have a defined tcp object otherwise this function will throw an error.
--- @param client Client The client to disconnect from a server
--- @return nil
function M.disconnect(client)
  -- Ensure the client has a tcp object
  if client.tcp == nil then
    return print("Client is not connected to a server, cannot disconnect.")
  end

  -- Close, shutdown and reset the connection
  -- Schedule is used to ensure the connection is killed at a valid time point in the event loop
  vim.schedule(function()
    -- Construct a server/disconnect event before shutting down TCP connection
    local event = require("docusync.client.events.constructor").events.server_disconnect(
      client.host,
      client.port,
      client.server_details.identifier
    )

    -- Send event to server
    if client.tcp:is_active() then
      client.tcp:write(event, function(write_err) assert(not write_err, write_err) end)
    else
      error("Failed to send event to server, connection is not active.")
    end

    -- Shutdown TCP connection
    client.tcp:close(function(err) assert(not err, err) end)
    client.tcp:shutdown(function(err) assert(not err, err) end)

    -- Null the client object fields
    client.tcp = nil
    client.server_details.identifier = ""
    client.server_details.capabilities = nil
  end)

  -- Print success message
  print("Disconnected from server! (" .. client.host .. ":" .. client.port .. ")")
end

-- Return module
return M
