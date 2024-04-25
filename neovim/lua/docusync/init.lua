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
      if err then
        print("Error connecting to host: " .. err)
        return
      end
      print("Connected to host: " .. M.conn.host .. ":" .. M.conn.port)
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

    -- Write data to the server
    local error = nil
    M.conn.tcp:write(data, function (err)
      error = err
    end)

    if error then
      print("Error writing to host: " .. error)
      return
    end

    print("Sent data to host: " .. M.conn.host .. ":" .. M.conn.port)
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
      return
    end

    M.conn.tcp = nil
    print("Closed connection to host: " .. M.conn.host .. ":" .. M.conn.port)
  end
end

function M.start()
end

-- Return module class
return M
