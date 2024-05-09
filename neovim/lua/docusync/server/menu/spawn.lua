--- Global configuration for the menus.
local config = {
  connected_clients = {
    size = {
      x = 42,
      y = 8,
    },
    padding = {
      x = 10,
      y = 0,
    }
  },
  client_buffers = {
    size = {
      x = 42,
      y = 8,
    },
    padding = {
      x = 10,
      y = 2,
    }
  }

}

--- server.menu.spawn module
return {

  --- Create a floating window that will display the connected clients.
  --- The float will display on the server's side.
  --- @param server Server The server object to display the connected clients.
  --- @return nil
  connected_clients = function(server)
    local bufnr = vim.api.nvim_create_buf(false, false)
    local winnr = vim.api.nvim_open_win(bufnr, false, {
      relative = "editor",
      style = "minimal",
      border = "rounded",
      col = vim.api.nvim_get_option_value("columns", {}) - config.connected_clients.padding.x,
      row = config.connected_clients.padding.y,
      width = config.connected_clients.size.x,
      height = config.connected_clients.size.y,
      title = "Connected Clients",
      title_pos = "center"
    })

    server.data.windows["connected_clients"] = winnr
  end,

  --- Create a floating window that will display the buffers that the clients
  --- are currently editing.
  --- @param server Server The server object to display the client buffers.
  --- @return nil
  client_buffers = function(server)
    local bufnr = vim.api.nvim_create_buf(false, false)
    local winnr = vim.api.nvim_open_win(bufnr, false, {
      relative = "editor",
      style = "minimal",
      border = "rounded",
      col = vim.api.nvim_get_option_value("columns", {}) - config.client_buffers.padding.x,
      row = config.connected_clients.size.y + config.client_buffers.padding.y,
      width = config.client_buffers.size.x,
      height = config.client_buffers.size.y,
      title = "Client Buffers",
      title_pos = "center"
    })

    server.data.windows["client_buffers"] = winnr


  end,
}
