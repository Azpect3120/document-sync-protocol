-- This file contains the parser for the server received events, responses and notifications.

-- Imports
local events = require("docusync.server.events.events")

--- Returns the type of a given data object.
--- @param data table The data object to get the type of.
--- @return string
local function get_type(data)
  if data.event then
    return "event"
  elseif data.notification then
    return "notification"
  elseif data.response then
    return "response"
  end

  return ""
end

return {
  --- Parse the data from the server and call the appropriate event.
  --- @param server Server The server object to parse the data for.
  --- @param data string The data to parse.
  --- @param conn uv_tcp_t The connection object that the data was received on.
  --- @return nil
  parse = function(server, data, conn)
    -- Decode the data and handle any errors.
    local status, res = pcall(vim.fn.json_decode, data)
    if not status then
      -- print("Error parsing provided data: " .. res)
      return
    end

    -- Store decoded data in a local variable
    local decoded = res

    -- If the data is nil, return
    if not decoded then return end

    -- Check if the data is an event, notification or response
    local type = get_type(decoded)
    if not type then
      return print("Invalid message type provided!")
    end

    -- Call appropriate event
    if type == "event" then
      if decoded.event == "server/connect" then
        events.server_connect(server, decoded, conn)
      elseif decoded.event == "server/disconnect" then
        events.server_disconnect(server, decoded)
      elseif decoded.event == "document/list" then
        events.document_list(server, decoded, conn)
      elseif decoded.event == "document/open" then
        events.document_open(server, decoded, conn)
      else
        print("Event: " .. decoded.event .. " not implemented!")
      end

    -- Call appropriate notification
    elseif type == "notification" then
      print("Notification received: " .. decoded.notification)

    -- Call appropriate response
    elseif type == "response" then
      print("Response received: " .. decoded.response)
    end
  end
}
