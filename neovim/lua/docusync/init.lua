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
  client = { host = "127.0.0.1", port = 3270, tcp = nil, server_details = { identifier = "", password = "", capabilities = nil } },
  -- Default server values
  server = { host = "127.0.0.1", port = 3270, tcp = nil, capabilities = capabilities.default(), connections = {} },
}

function M.test_suite()
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local spawned_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(spawned_bufnr, "buftype", "nofile")

  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_command("botright vnew")

  local spawned_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(spawned_win, spawned_bufnr)

  vim.api.nvim_set_current_win(cur_win)

  local cur_lines = vim.api.nvim_buf_get_lines(cur_bufnr, 0, -1, false)
  vim.api.nvim_buf_set_lines(spawned_bufnr, 0, -1, false, cur_lines)


  local last_lines = vim.api.nvim_buf_get_lines(cur_bufnr, 0, -1, false)

  vim.api.nvim_buf_attach(cur_bufnr, false, {
    -- on_bytes = function(bytes, buffer, change_tick, start_row, star_col, byte_offset, old_end_row, old_end_byte_length, new_end_row, new_end_col, new_end_byte_length)

    on_bytes = function()
      local new_lines = vim.api.nvim_buf_get_lines(cur_bufnr, 0, -1, false)

      for i, line in ipairs(new_lines) do
        if last_lines[i] ~= line then
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(spawned_bufnr, i - 1, i, false, { line })
          end)
        elseif last_lines[i] == nil then
          vim.schedule(function()
            vim.api.nvim_buf_set_lines(spawned_bufnr, i - 1, i, false, { "" })
          end)
        end
      end

      if #new_lines < #last_lines then
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(spawned_bufnr, #new_lines, -1, false, {})
        end)
      end

      last_lines = new_lines
    end,
  })

end

function M.dump_server()
  print(vim.inspect(M.server))
end

function M.dump_client()
  print(vim.inspect(M.client))
end

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
