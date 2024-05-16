-- This file contains the callbacks for each client event that has been parsed

return {
  --- Ran by the user who wishes to disconnect from the server. The callers
  --- files will remain unchanged until the connection is re-established. The
  --- connection is expected to be closed once this event is emitted, hence,
  --- no response is expected.
  ---
  --- This function is responsible for handling the server/disconnect event.
  --- It will close the clients connection as well as inform them of the server
  --- being closed. With this event, the client does NOT need to emit the
  --- client/disconnect event.
  --- @param event table The event object that was parsed
  --- @param client Client The client object
  --- @return nil
  server_stop = function(event, client)
    -- Notify the client that the server is stopping
    print("Server has been stopped by host " .. event.host)

    -- Close the clients TCP connection
    vim.schedule(function()
      client.tcp:close(function(err) assert(not err, err) end)
      client.tcp:shutdown(function(err) assert(not err, err) end)

      -- Null the client object fields
      client.tcp = nil
      client.server_details.identifier = ""
      client.server_details.capabilities = nil
    end)
  end,

  --- The `document/sync` event is emitted by the server whenever a client updates the document. The server will then
  --- send the updated document to all connected clients. The client will then update their document with the new content.
  --- The server will also send the updated document to the client who emitted the `document/update` event. This is to
  --- ensure that the client has the most up-to-date document content. The files content should be in a line-by-line format.
  --- The client will handle the data by ["diffing"](https://neovim.io/doc/user/lua.html#vim.diff) each line and updating
  --- the clients page with the new content. This event works together with the `document/update` event to keep all the client
  --- and the server in sync.
  ---
  --- This function is responsible for handling the document/sync event. It will update the clients document with the new
  --- content that was sent by the server. The client will then update their document with the new content. The client will
  --- handle the data by "diffing" each line and updating the clients page with the new content. This event works together
  --- with the document/update event to keep all the client and the server in sync.
  --- @param event table The event object that was parsed
  --- @param client Client The client object
  --- @return nil
  document_sync = function(event, client)
    -- Get the buffer number for the document
    local bufnr = client.server_details.buffers[event.document]

    -- Buffer is not opened by the client
    if not bufnr then
      print("Document not found in clients buffer list")
      return
    end

    -- Schedule the update to happen in the next safe tick
    vim.schedule(function()
      -- update the clients buffer with the new content: diff
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      -- namespace for the virtual text
      local ns = vim.api.nvim_create_namespace("docusync_virtualtext")

      for i, line in ipairs(event.content) do
        if lines[i] ~= line then
          vim.schedule(function()
            -- update line content
            vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { line })

            -- update virtual text
            vim.api.nvim_buf_set_extmark(
              bufnr,
              ns,
              i - 1,
              0,
              {
                id = i - 1,
                sign_text = " !",
                sign_hl_group = "cursorlinesign",
              }
            )
          end)
        elseif lines[i] == nil then
          vim.schedule(function()
            -- update line content
            vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { line })

            -- update virtual text
            vim.api.nvim_buf_set_extmark(
              bufnr,
              ns,
              i - 1,
              0,
              {
                id = i - 1,
                sign_text = " !",
                sign_hl_group = "cursorlinesign",
              }
            )
          end)
        end
      end

      -- if lines were removed, clear them from the end of the file
      -- brilliant fix right here
      if #event.content < #lines then
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, #event.content, -1, false, {})
        end)
      end
    end)
  end,
}
