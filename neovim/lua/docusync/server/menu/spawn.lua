--- server.menu.spawn module
return {
  --- Create a floating window that will display the connected clients.
  --- The float will display on the server's side.
  ---
  --- @param server Server The server object to display the connected clients.
  --- @return nil
  connected_clients = function(server)
    local size_x = 52
    local size_y = 8
    local padding_x = 10
    local padding_y = 1

    local bufnr = vim.api.nvim_create_buf(false, false)
    local winnr = vim.api.nvim_open_win(bufnr, false, {
      relative = "editor",
      style = "minimal",
      border = "rounded",
      col = vim.api.nvim_get_option_value("columns", {}) - padding_x,
      row = padding_y,
      width = size_x,
      height = size_y,
      title = "Connected Clients",
      title_pos = "center"
    })
  end,
}
