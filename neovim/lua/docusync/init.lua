-- Globals
local uv = vim.loop
local host, port = "127.0.0.1", 3270

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
    host = "127.0.0.1",
    port = 3270,
  },
  server = {
    tcp = nil,
    host = "127.0.0.1",
    port = 3270,
  }
}

--- Connect to the server
function M.connect ()
  if M.conn == nil or M.conn.tcp == nil then
    -- Create TCP objects on the connection field
    M.conn.tcp = uv.new_tcp()

    -- Nil check on the tcp object
    if M.conn.tcp == nil then
      print("Error connecting to host: tcp is nil")
      return
    end

    -- Set connection host and port
    M.conn.host = host
    M.conn.port = port

    -- Connect to the host
    M.conn.tcp:connect(M.conn.host, M.conn.port, function (err)
      assert(not err, err)
      print("Connected to host: " .. M.conn.host .. ":" .. M.conn.port)

      -- Read data from the server
      -- THIS WORKS!!!
      M.conn.tcp:read_start(function (read_err, chunk)
        assert(not read_err, read_err)
        if chunk then
          print("Data received: " .. chunk)
        end
      end)

    end)
  else
    -- Already connected or TCP object exists on the connection field
    print("Already connected to " .. M.conn.host .. ":" .. M.conn.port)
  end
end

--- Send data to the server
--- A connection must be established before sending data
--- @param data string
function M.send (data)
  if M.conn == nil or M.conn.tcp == nil then
    print("Error sending data: connection is nil")
  else
    -- Ensure the data ends with a \n
    -- This is a temporary requirement for the server to process the data
    if not (string.sub(data, -1) == '\n') then
      data = data .. '\n'
    end

    -- Attempt to keep connection alive
    M.conn.tcp:keepalive(true, 0)

    -- Write data to the server
    local bytes = M.conn.tcp:try_write(data)

    print("Sent data to host: " .. M.conn.host .. ":" .. M.conn.port)
    print("Data(" .. bytes .. "): " .. data)
  end
end

--- Close the connection to the server
function M.close()
  if M.conn == nil or M.conn.tcp == nil then
    print("Error closing connection: connection is nil")
  else
    -- Close the connection
    local error = nil
    M.conn.tcp:close(function (err)
      error = err
    end)
    if error then
      print("Error closing connection: " .. error)
    end

    M.conn.tcp:shutdown(function (err)
      error = err
    end)
    if error then
      print("Error shutting down connection: " .. error)
    end

    M.conn.tcp = nil
    print("Closed connection to host: " .. M.conn.host .. ":" .. M.conn.port)
  end
end

--- Handle a new connection
--- @param client uv_tcp_t
local function on_connect (client)
  client:read_start(function (err, chunk)
    assert(not err, err)  -- This line throws when a client disconnects
    if chunk then
      client:write(chunk)
      print("Data received: " .. chunk)
    end
  end)
end

-- Start a server which listens for incoming connections
function M.start()
  if M.server == nil or M.server.tcp == nil then
    -- Create TCP objects on the server field
    M.server.tcp = vim.loop.new_tcp()

    -- Bind the server to the host and port
    local success, error, message = M.server.tcp:bind(M.server.host, M.server.port)
    if error or not success then
      print("Error: "..error .. " Message: "..message)
    else
      print("Server started on host: " .. M.server.host .. ":" .. M.server.port)
    end

    -- Listen for connections
    M.server.tcp:listen(128, function (err)
      -- Check for errors
      assert(not err, err)

      -- Accept the client
      local client = vim.loop.new_tcp()
      M.server.tcp:accept(client)
      print("Accepted connection from " .. client:getpeername().ip .. ":" .. client:getpeername().port)

      -- Run read-loop on the client
      on_connect(client)
    end)
  else
    print("Server already running on " .. M.server.host .. ":" .. M.server.port)
  end
end

-- Stop the server running on the host
function M.stop()
  if M.server == nil or M.server.tcp == nil then
    print("Error stopping server: connection is nil")
  else
    -- Close the connection
    local error = nil
    M.server.tcp:close(function (err)
      assert(not err, err)
    end)
    if error then
      print("Error closing connection: " .. error)
    end

    M.server.tcp:shutdown(function (err)
      assert(not err, err)
    end)
    if error then
      print("Error shutting down connection: " .. error)
    end

    M.server.tcp = nil
    print("Stopped server on host: " .. M.server.host .. ":" .. M.server.port)
  end
end

-- Return module class
return M
