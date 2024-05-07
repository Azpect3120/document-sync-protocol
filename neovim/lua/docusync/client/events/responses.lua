-- This file contains the callbacks for each client response that has been parsed

-- Telescope imports
local ts_pickers = require "telescope.pickers"
local ts_finders = require "telescope.finders"
local ts_conf = require("telescope.config").values
local ts_actions = require "telescope.actions"
local ts_action_state = require "telescope.actions.state"

return {
  --- This response will be sent to only the client who emitted the
  --- ConnectServerEvent. The NewClientConnectionNotification will be
  --- emitted to all connected clients.
  ---
  --- This function will update the data in the client object with the
  --- the data from the server response.
  --- @param client Client The client object
  --- @param response table The response data
  --- @return nil
  server_connect = function(client, response)
    -- Ensure the response indicates success
    if not response.success then
      return print("Error connecting to server: " .. response.error)
    end

    -- Update the clients identifier and capabilities
    client.server_details.identifier = response.identifier
    client.server_details.capabilities = response.capabilities

    -- Print success message
    print("Connected to server as: " .. response.identifier)
  end,

  --- This is the response returned by the server a client emits the `document/list` event.
  ---
  --- This function will handle the response from the server and display the list using a
  --- telescope picker. Only the OPENED documents will be in the response.
  --- @param client Client The client object
  --- @param response table The response data
  --- @return nil
  document_list = function(client, response)
    if not response.status then
      return print("Error retrieving document list: " .. response.error)
    end

    -- Create a telescope picker to display the list of documents
    ts_pickers.new({}, {
      -- Define what happens when a document is selected
      attach_mappings = function(prompt_bufnr, _)
        ts_actions.select_default:replace(function()
          ts_actions.close(prompt_bufnr)
          -- Get the selected entry
          local bufname = ts_action_state.get_selected_entry()[1]

          -- The buffer is already open, switch to it
          if (client.server_details.buffers[bufname]) then
            local bufnr = client.server_details.buffers[bufname]
            vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), bufnr)

            -- But we still need to send the document/open event to the server
            -- Construct the document/open event
            local event = require("docusync.client.events.constructor").events.document_open(
              client.server_details.identifier, bufname)

            -- Send event to the server
            client.tcp:write(event, function(write_err)
              if write_err then error("Error writing event to server: " .. write_err) end
            end)

            return
          end

          -- Create a new buffer and set the name to the selected document
          -- Set the current window to the new buffer
          local bufnr = vim.api.nvim_create_buf(true, false)
          vim.api.nvim_buf_set_name(bufnr, "docusync:///" .. bufname)
          vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), bufnr)

          -- Trying to provide syntax highlighting 
          -- However this does not provide LSP support bc the root dir is not set
          -- WIP: This is a good start, but needs to be improved
          vim.cmd("filetype detect")

          -- Add the buffer to the client object
          client.server_details.buffers[bufname] = bufnr

          -- Construct the document/open event
          local event = require("docusync.client.events.constructor").events.document_open(
            client.server_details.identifier, bufname)

          -- Send event to the server
          client.tcp:write(event, function(write_err)
            if write_err then error("Error writing event to server: " .. write_err) end
          end)
        end)
        return true
      end,
      prompt_title = "Opened Documents",
      finder = ts_finders.new_table {
        -- Load the documents into the picker
        results = response.documents,
      },
      sorter = ts_conf.generic_sorter(require("telescope.themes").get_dropdown {})
    }):find()
  end,

  --- The `document/open` response is emitted by the server whenever a client opens a document. The server will then send the
  --- content of the document to the client. The name of the document is the path of the document relative to the root in which
  --- Neovim was opened in. The content will be sent back to the client in a line-by-line format. This response is only sent to
  --- the client who emitted the `document/open` event.
  ---
  --- This function will update the data in the client object with the data from the server response. It will take the content
  --- from the server response and set the content of the buffer with the same name as the document.
  --- @param client Client The client object
  --- @param response table The response data
  --- @return nil
  document_open = function(client, response)
    -- Ensure the response indicates success
    if not response.status then
      return print("Error opening document: " .. response.error)
    end

    -- Get the buffer number from the client object
    local bufnr = client.server_details.buffers[response.document]

    -- Write the content to the buffer
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, response.content)
    end)
  end,
}
