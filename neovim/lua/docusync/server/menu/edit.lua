return {

  --- Update the list of connected clients in the connected clients window.
  --- This function is called any time a client connects or disconnects from 
  --- the server.
  --- @param server Server The server object to get the client list from.
  --- @return nil
  connected_clients = function (server)
    local clients = {}
    for identifier, _ in pairs(server.connections) do
      table.insert(clients, " " .. identifier)
    end

    local bufnr = vim.api.nvim_win_get_buf(server.data.windows["connected_clients"])
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, clients)
    end)
  end,

  --- Update the list of buffers being edited by the clients window.
  --- This function is called any time a client opens or closes a buffer. As
  --- well as any time a client connects or disconnects from the server.
  --- @param server Server The server object to get the buffer list from.
  --- @return nil
  client_buffers = function (server)
    local lines = {}
    for identifier, buffer in pairs(server.data.client_buffers) do
      if buffer == "" then
        table.insert(lines, " " .. identifier .. ": " .. "waiting...")
      else
        table.insert(lines, " " .. identifier .. ": " .. buffer)
      end
    end

    local bufnr = vim.api.nvim_win_get_buf(server.data.windows["client_buffers"])
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    end)
  end,
}
