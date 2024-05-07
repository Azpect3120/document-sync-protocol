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

  --- This is the response returned by the server a client emits the `document/list` event.
  --- 
  --- This function will handle the response from the server and FOR NOW just print the 
  --- documents to the console. Only the OPENED documents will be in the response.
  --- @param client Client The client object
  --- @param response table The response data
  --- @return nil
  document_list = function(client, response)
    if not response.status then
      return print("Error retrieving document list: " .. response.error)
    end

    -- Print the documents to the console
    print("Documents: ")
    for _, document in ipairs(response.documents) do
      print("  - " .. document)
    end
  end,
}
