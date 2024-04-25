-- Imports
local tcp = require("docusync.tcp")

--- @class Plugin
--- @field conn Connection | nil
--- @field server Server | nil
local M = {
  conn = nil,
  server = nil
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

function M.start()
  M.server = tcp.start()
end

 --   Error executing Lua callback: ...rojects/DocumentSyncProtocol/neovim/lua/docusyn 
 -- nc/tcp.lua:95: attempt to index local 'server' (a nil value) 
 -- stack traceback: 
 -- ...rojects/DocumentSyncProtocol/neovim/lua/docusync/tcp.lua:95: in function 'st 
 -- tart' 
 -- ...ojects/DocumentSyncProtocol/neovim/lua/docusync/init.lua:42: in function 'st 
 -- tart' 
 -- ...s/Projects/DocumentSyncProtocol/neovim/plugin/client.lua:21: in function <.. 
 -- ..s/Projects/DocumentSyncProtocol/neovim/plugin/client.lua:12> 

return M
