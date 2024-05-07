--- @class ServerData
--- @field buffers table<string, number> A table of buffers that are active on the server. The key is the buffer's file name and the value is the buffer number.

--- @class Server
--- @field host string Host the server is running on.
--- @field port number Port the server is running on.
--- @field tcp uv_tcp_t | nil The TCP handle for the server.
--- @field capabilities Capabilities | nil The capabilities of the server.
--- @field connections table<string, uv_tcp_t> A table of connections to the server. The value is the TCP handle and the key is the client identifier.
--- @field data ServerData The data that is stored and modified while it is running.
