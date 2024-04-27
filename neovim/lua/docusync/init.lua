-- Globals
local uv = vim.loop

-- Main classes
--- @class Connection
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil

--- @class Server
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil

--- @class Module
--- @field conn Connection
--- @field server Server
local M = {
  conn = {
    tcp = nil,
    host = "127.0.0.1", -- Default host
    port = 3270,        -- Default port
  },
  server = {
    tcp = nil,
    host = "127.0.0.1", -- Default host
    port = 3270,        -- Default port
  }
}

--- Handle a connections read loop.
--- This function can be used on both a server and a client to read all incoming data.
--- This function will throw an error if the client disconnects.
--- @param client uv_tcp_t
local function connection_read_loop(client)
  client:read_start(function(err, chunk)
    assert(not err, err) -- This line throws when a client disconnects
    if chunk then
      -- client:write(chunk)  -- This line will echo the data back to the send
      print("Data received: " .. chunk)
    end
  end)
end

--- Connect to the server.
--- This function will throw an error if the client is already connected to a(any) server.
--- A host and port can be provided to connect to a specific server, otherwise the default will be used (127.0.0.1:3270).
--- @param host string | nil
--- @param port number | nil
--- @return nil
function M.connect(host, port)
  -- Ensure the client is not already connected
  assert(M.conn.tcp == nil, "Error connecting: client is already connected to a server")

  -- Create TCP objects on the connection field
  M.conn.tcp = uv.new_tcp()

  -- Nil check on the tcp object
  assert(M.conn.tcp, "Error creating TCP object")

  -- Set connection host and port if they are provided
  M.conn.host = host or M.conn.host
  M.conn.port = port or M.conn.port

  -- Connect to the host
  M.conn.tcp:connect(M.conn.host, M.conn.port, function(err)
    -- Check for errors
    assert(not err, err)

    -- Read data from the server
    connection_read_loop(M.conn.tcp)

    -- Print success message
    print("Connected to host: " .. M.conn.host .. ":" .. M.conn.port)
  end)
end

--- Send data to the connected server.
--- A connection must be established before sending data.
--- This function will throw an error if a connection does not exist.
--- This function will also throw an error if no bytes are written.
--- The number of bytes written will be returned.
--- @param data string
--- @return integer
function M.send(data)
  -- Ensure a connection exists before sending
  assert(M.conn and M.conn.tcp, "Error sending data: connection is nil")

  -- Write data to the server
  local bytes = M.conn.tcp:try_write(data)

  -- Check if data was sent
  assert(bytes ~= 0, "Error sending data: no bytes written")

  -- Print success message and return
  print("Sent " .. bytes .. " bytes to host: " .. M.conn.host .. ":" .. M.conn.port)
  return bytes
end

--- Close the connection to the server.
--- A connection must be established before closing.
--- This function will throw an error if a connection does not exist.
--- This function makes use of vim.schedule to ensure the connection is closed in the next event loop.
--- @return nil
function M.close()
  -- Ensure a connection exists before closing
  assert(M.conn.tcp, "Error closing connection: connection is nil")

  -- Close, shutdown and reset the connection
  vim.schedule(function()
    M.conn.tcp:close(function(err) assert(not err, err) end)
    M.conn.tcp:shutdown(function(err) assert(not err, err) end)
    M.conn.tcp = nil
  end)

  -- Print success message
  print("Closed connection to host: " .. M.conn.host .. ":" .. M.conn.port)
end

--- Start a server which listens for incoming connections
--- This function will throw an error if the server is already running.
--- Connection requests will be accepted and a read-loop will be run on the client.
--- A host and port can be provided to start the server on a specific host and port, otherwise the default will be used (127.0.0.1:3270).
--- @param host string | nil
--- @param port number | nil
--- @return nil
function M.start(host, port)
  -- Ensure the server is not already running
  assert(M.server.tcp == nil, "Error starting server: server is already running")

  -- Update the server class object
  M.server.tcp = uv.new_tcp()
  M.server.host = host or M.server.host
  M.server.port = port or M.server.port

  -- Bind the server to the host:port and handle error
  local success, error, _ = M.server.tcp:bind(M.server.host, M.server.port)
  assert(success, error)

  -- Print success message
  print("Server started on host: " .. M.server.host .. ":" .. M.server.port)

  -- Listen for connections
  M.server.tcp:listen(128, function(err)
    -- Check for errors
    assert(not err, err)

    -- Accept the client
    local client = uv.new_tcp()
    M.server.tcp:accept(client)
    print("Accepted connection from " .. client:getpeername().ip .. ":" .. client:getpeername().port)

    -- Run read-loop on the client
    connection_read_loop(client)
  end)
end

--- Stop the server running on the host.
--- The server must exist before stopping.
--- This function will throw an error if the server is nil.
--- This function makes use of vim.schedule to ensure the server is stopped in the next event loop.
--- @return nil
function M.stop()
  -- Ensure the server exists before stopping
  assert(M.server.tcp, "Error stopping server: server is nil")

  -- Close, shutdown and reset the server
  vim.schedule(function()
    M.server.tcp:close(function(err) assert(not err, err) end)
    M.server.tcp:shutdown(function(err) assert(not err, err) end)
    M.server.tcp = nil
  end)

  -- Print success message
  print("Stopped server on host: " .. M.server.host .. ":" .. M.server.port)
end

-- Return module class
return M
