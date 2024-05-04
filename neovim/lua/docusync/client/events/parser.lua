-- This file contains the parser for the client received events, responses and notifications.

-- Imports
local events = require("docusync.client.events.events")
local responses = require("docusync.client.events.responses")
local notifications = require("docusync.client.events.notifications")

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
  --- Parse the data from the client and call the appropriate event.
  --- @param client Client The client object to parse the data for.
  --- @param data string The data to parse.
  --- @return nil
  parse = function(client, data)
    -- Decode the data and handle any errors.
    local status, res = pcall(vim.fn.json_decode, data)
    if not status then
      print("Error parsing provided data: " .. res)
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
      print("Event received: " .. decoded.event)

    -- Call appropriate notification
    elseif type == "notification" then
      if decoded.notification == "client/connect" then
        notifications.client_connect(decoded)
      elseif decoded.notification == "client/disconnect" then
        notifications.client_disconnect(decoded)
      end

    -- Call appropriate response
    elseif type == "response" then
      if decoded.response == "server/connect" then
        responses.server_connect(client, decoded)
      end
    end
  end

}
