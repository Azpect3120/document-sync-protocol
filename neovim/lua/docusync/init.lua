-- Imports
local tcp = require("docusync.tcp")

--- @class Plugin
--- @field conn Connection | nil
local M = {
  conn = nil
}

--- Connect to the server
function M.connect ()
  if M.conn ~= nil then
    print("A connection already active. Close it first.")
  else
    M.conn = tcp:connect()
  end
end

--- Send data to the server
--- @param data string
function M.send (data)
  if M.conn == nil then
    print("No active connection to send data to.")
  else
    M.conn:send(data)
  end
end

--- Close the connection to the server
function M.close()
  if M.conn == nil then
    print("No active connection to close.")
  else
    M.conn:close()
    M.conn = nil
  end
end

return M
