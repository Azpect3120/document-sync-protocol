-- Globals
local uv = vim.loop
local events = require("docusync.parser.events")
local c_update = require("docusync.client.update")
local s_sync = require("docusync.server.sync")

-- Main classes
--- @class Connection
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil
--- @field cmds table<number, string>

--- @class Server
--- @field host string
--- @field port number
--- @field tcp uv_tcp_t | nil
--- @field connections table<uv_tcp_t, uv_tcp_t>
--- @field timer uv_timer_t | nil
--- @field f_update boolean Should the server update the document
--- @field cmds table<number, string>

--- @class Module
--- @field conn Connection
--- @field server Server
local M = {
  conn = {
    tcp = nil,
    host = "127.0.0.1", -- Default host
    port = 3270,        -- Default port
    cmds = {}           -- Command IDs
  },
  server = {
    tcp = nil,
    host = "127.0.0.1", -- Default host
    port = 3270,        -- Default port
    connections = {},    -- Connections
    timer = nil,
    f_update = false,
    cmds = {},
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
      -- This is temporary until I figure out how to parse the data
      vim.schedule(function()
        events.parse(M.server, chunk)
      end)
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

    -- Get document information and start the event loop
    vim.schedule(function()
      local bufnr = vim.api.nvim_get_current_buf()
      local document = vim.api.nvim_buf_get_name(bufnr)
      local identifier = "Azpect" -- hard coded for now
      local cmd_id = c_update.on_save(M.conn, document, identifier, bufnr)

      -- Add the command to the connection commands table
      -- This is used to stop the commands when the connection is closed
      M.conn.cmds[cmd_id] = "document/update"
    end)

    -- Print success message
    print("Connected to host: " .. M.conn.host .. ":" .. M.conn.port)
  end)
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

  -- Stop all commands running
  for cmd_id in pairs(M.conn.cmds) do
    vim.api.nvim_del_autocmd(cmd_id)
  end

  -- Reset commands table
  M.conn.cmds = {}

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
  assert(M.server.timer == nil, "Error starting server: server timer is already running")

  -- Update the server class object
  M.server.tcp = uv.new_tcp()
  M.server.host = host or M.server.host
  M.server.port = port or M.server.port

  -- Bind the server to the host:port and handle error
  local success, error, _ = M.server.tcp:bind(M.server.host, M.server.port)
  assert(success, error)

  -- Print success message
  print("Server started on host: " .. M.server.host .. ":" .. M.server.port)

  -- Get data of the current buffer and start the update event loop
  local bufnr = vim.api.nvim_get_current_buf()
  local document = vim.api.nvim_buf_get_name(bufnr)
  M.server.timer = s_sync.start_sync_loop(M.server, document, bufnr)

  -- Using the data start the on_save loop
  local cmd_id = s_sync.on_save(M.server, document, bufnr)
  M.server.cmds[cmd_id] = "server/f_update"

  -- Listen for connections
  M.server.tcp:listen(128, function(err)
    -- Check for errors
    assert(not err, err)

    -- Accept the client
    local client = uv.new_tcp()
    M.server.tcp:accept(client)
    print("Accepted connection from " .. client:getpeername().ip .. ":" .. client:getpeername().port)

    -- Add the client to the connections table
    M.server.connections[client] = client

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
  assert(M.server.timer, "Error stopping server: server timer is nil")

  -- Close, shutdown and reset the server
  vim.schedule(function()
    M.server.timer:stop()
    M.server.timer:close()
    M.server.timer = nil

    M.server.tcp:close(function(err) assert(not err, err) end)
    M.server.tcp:shutdown(function(err) assert(not err, err) end)
    M.server.tcp = nil

    -- Stop all commands running
    for cmd_id in pairs(M.server.cmds) do
      vim.api.nvim_del_autocmd(cmd_id)
    end
  end)

  -- Print success message
  print("Stopped server on host: " .. M.server.host .. ":" .. M.server.port)
end

-- Return module class
return M
