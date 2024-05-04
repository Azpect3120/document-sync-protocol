-- This file contains the callbacks for each client response that has been parsed

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
}
