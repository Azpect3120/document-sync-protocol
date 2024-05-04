-- This is the main plugin module.
-- All state should start and end here!

-- Package imports
local tcp = require("docusync.tcp")
local capabilities = require("docusync.capabilities")

-- This is where the state is stored.
---@class DocuSync
---@field client Client
---@field server Server
local M = {
  -- Default client values
  client = { host = "127.0.0.1", port = 3270, tcp = nil, capabilities = nil },
  -- Default server values
  server = { host = "127.0.0.1", port = 3270, tcp = nil, capabilities = capabilities.default(), connections = {} },
}

--- Connect to a tcp server and store the connection on the client object.
--- The host and port arguments can be blank to use the default values.
--- @param host string|nil the host to connect to, defaults to 127.0.0.1
--- @param port number|nil the port to connect to, defaults to 3270
function M.connect(host, port)
  -- Use the provided values if provided
  M.client.host = host or M.client.host
  M.client.port = port or M.client.port

  -- Nil check on the tcp object
  assert(M.client.tcp == nil, "Already connected to a server, Disconnect first.")

  -- Connect to the server
  tcp.client.connect(M.client)
end

--- Disconnect from a tcp server and remove the connection from the client object.
--- @return nil
function M.disconnect()
  -- Ensure the client has a tcp object
  assert(M.client.tcp, "Client is not connected to a server, cannot disconnect.")

  -- Disconnect from the server
  tcp.client.disconnect(M.client)
end

--- Start a tcp server and store the connection on the server object.
--- @param host string|nil the host to connect to, defaults to 127.0.0.1
--- @param port number|nil the port to connect to, defaults to 3270
--- @return nil
function M.start_server(host, port)
  -- Use the provided values if provided
  M.server.host = host or M.server.host
  M.server.port = port or M.server.port

  -- Nil check on the tcp object
  assert(M.client.tcp == nil, "Server is already running, Stop the server first.")

  -- TODO: Implement the server capabilities
  M.server.capabilities = capabilities.default() -- or capabilities.new(...)

  -- Start the server
  tcp.server.start_server(M.server)
end

--- Stop a tcp server and remove the connection from the server object.
--- @return nil
function M.stop_server()
  -- Ensure the server has a tcp object
  assert(M.server.tcp, "Server is not running, cannot stop the server.")

  -- Stop the server
  tcp.server.stop_server(M.server)
end

return M
