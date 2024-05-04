return {
  --- This response will be sent to only the client who emitted the 
  --- ConnectServerEvent. The NewClientConnectionNotification will 
  --- be emitted to all connected clients.
  --- @param response string The encoded response to parse
  --- @return nil
  connect_to_server = function (response)
    -- Decode the response
    local decoded = vim.fn.json_decode(response)

    -- Assert the response was decoded
    assert(decoded, "Error decoding response")

    -- Print message
    if (decoded.success) then
      print("Connected to server with identifier " .. decoded.identifier)
    else
      print("Failed to connect to server: " .. decoded.error)
    end

    -- TODO: Update the clients capabilities which are provided by 
    -- the server in this event.
  end,
}
