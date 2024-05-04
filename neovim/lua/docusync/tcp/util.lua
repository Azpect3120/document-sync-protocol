-- tcp.util module
local M = {}

--- Handle a connections read loop.
--- This function can be used on both a server and a client to read all incoming data.
--- This function will throw an error if the client disconnects.
--- @param conn uv_tcp_t
--- @param callback function(error, string)
function M.connection_read_loop(conn, callback)
  conn:read_start(callback)
end

-- Return module
return M
