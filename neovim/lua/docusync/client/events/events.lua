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
}
