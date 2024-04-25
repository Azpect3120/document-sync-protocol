local uv = vim.loop
local host, port = "127.0.0.1", 3270

--- @class Connection
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil
local M = {}

--- Connect to the host
--- @param conn Connection
--- @return Connection
function M.connect (conn)
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
function M.send(conn, data)
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
function M.close(conn)
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

return M
