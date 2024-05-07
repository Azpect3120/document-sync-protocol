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
  client = { host = "127.0.0.1", port = 3270, tcp = nil, server_details = {identifier = "", password = "", capabilities = nil, buffers = {}} },
  -- Default server values
  server = { host = "127.0.0.1", port = 3270, tcp = nil, capabilities = capabilities.default(), connections = {}, data = { buffers = {} } },
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
    -- This kinda works? Sending back entire lines though not (row, columns)
    -- FIRST TEST: This can be used to set virtual text, basically all its for
    -- on_lines = function(_, bufnr, _, first_line, last_line)
    --   local lines = vim.api.nvim_buf_get_lines(bufnr, first_line, last_line, false)
    --   print(first_line .. ":" .. last_line .. " " .. vim.inspect(lines))
    --
    --   local ns = vim.api.nvim_create_namespace("docusync_testing_suite")
    --
    --
    --   -- Creating virtual text
    --   vim.api.nvim_buf_set_extmark(
    --     bufnr,
    --     ns,
    --     first_line,
    --     0,
    --     {
    --       id = first_line,
    --       virt_text = { { "NOT SYNCED", "Comment" } },
    --       virt_text_pos = "eol",  -- right_align
    --
    --       -- Add stuff to the gutter
    --       -- THIS COULD BE USED TO IDENTIFY WHO CHANGED THIS LINE
    --       sign_text = " !",
    --       sign_hl_group = "CursorLineSign",
    --     }
    --   )
    --
    --   -- Delete the virtual text after 1 second
    --   vim.loop.new_timer():start(1000, 0, vim.schedule_wrap(function()
    --     vim.api.nvim_buf_del_extmark(bufnr, ns, first_line)
    --   end))
    --
    -- end,

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

--- Get the list of open documents from the server.
--- This will send a request to the server to get the list of open documents.
--- The server will respond with a list of open documents which triggers a 
--- telescope picker to display the list.
--- @return nil
function M.document_list()
  -- Ensure the client is connected to a server
  assert(M.client.tcp, "Client is not connected to a server, cannot get document list.")

  -- Create the event to get the list of open documents
  local event = require("docusync.client.events.constructor").events.document_list(M.client.server_details.identifier)

  -- Send the event to the server
  M.client.tcp:write(event, function(err)
    assert(not err, err)
  end)
end

return M
