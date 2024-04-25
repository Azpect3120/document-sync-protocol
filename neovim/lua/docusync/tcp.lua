local uv = vim.loop
local host, port = "127.0.0.1", 3270

--- @class Connection
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil
local C = {}

--- @class Server
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil
local S = {}

--- Connect to the host
--- @param conn Connection
--- @return Connection
function C.connect (conn)
  conn.tcp = uv.new_tcp()

  -- Nil check on the tcp object
  if conn.tcp == nil then
    print("Error connecting to host: tcp is nil")
    return conn
  end

  -- Connect to the host
  conn.tcp:connect(host, port, function (err)
    if err then
      print("Error connecting to host: " .. err)
      return
    end
    print("Connected to host: " .. host .. ":" .. port)
  end)

  return conn
end

--- Send data to the host
--- @param conn Connection
--- @param data string
--- @return boolean
function C.send(conn, data)
  -- Ensure connected
  if conn.tcp == nil then
    print("Error sending data: tcp is nil")
    return false
  end

  -- Ensure the data ends with a \n
  if not (string.sub(data, -1) == '\n') then
    data = data .. '\n'
  end

  local success = true
  conn.tcp:write(data, function (err)
    if err then
      print("Error writing to host: " .. err)
      success = false
      return
    end
  end)
  return success
end

--- Close the connection
--- @param conn Connection
--- @return boolean
function C.close(conn)
  -- Ensure connected
  if conn.tcp == nil then
    print("Error closing connection: tcp is nil")
    return false
  end

  local success = true
  conn.tcp:close(function (err)
    if err then
      print("Error closing connection: " .. err)
      success = false
      return
    end
  end)
  print("Connection to host closed.")

  conn.tcp = nil
  return success
end

--- Start a server
--- @return Server
function C.start()
  local server = S
  server.tcp = uv.new_tcp()

  local success = server.tcp:bind(host, port)
  if not success then
    print("Error binding server to host: " .. host .. ":" .. port)
    return server
  end

  server.tcp:listen(5, function (err)
    if err then
      print("Error listening on host: " .. err)
      return
    end

    print("Server is listening on host: " .. host .. ":" .. port)
  end)

  return server
end

return C
