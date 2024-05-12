return {
  --- Update the list of buffers being edited by the clients window.
  --- This function is called any time a client opens or closes a buffer. As
  --- well as any time a client connects or disconnects from the server.
  --- @param server Server The server object to get the buffer list from.
  --- @return nil
  connected_clients = function (server)
    local lines = {}
    for identifier, buffer in pairs(server.data.client_buffers) do
      if buffer == "" then
        table.insert(lines, " " .. identifier .. ": " .. "waiting...")
      else
        table.insert(lines, " " .. identifier .. ": " .. buffer)
      end
    end

    local bufnr = vim.api.nvim_win_get_buf(server.data.windows["connected_clients"])
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end,
}
