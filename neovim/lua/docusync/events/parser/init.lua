-- Imports
local events = require("docusync.events.parser.events")
local notifications = require("docusync.events.parser.notifications")
local responses = require("docusync.events.parser.responses")

-- events.parser module
local M = {}

--- Parse an event and call the matching function.
--- Will return true if the event was parsed successfully.
--- Will return false if the event was not parsed successfully, 
--- or if the event is not supported.
--- @param event string The encoded event to parse
--- @param client Client The client object to use
--- @param server Server The server object to use
--- @return boolean
function M.parse_event(event, client, server)
  -- Decode the event
  local decoded = vim.fn.json_decode(event)

  -- Ensure the event was decoded
  if not decoded then
    return false
  end

  -- Match the event and call proper functions
  if (decoded.event == "server/connect") then
    events.server_connect(event, client, server)
    return true
  elseif (decoded.event == "server/disconnect") then
    events.server_disconnect(event)
    return true
  elseif (decoded.event == "document/sync") then
    events.document_sync(event)
    return true
  elseif (decoded.event == "document/update") then
    events.document_update(event)
    return true
  end

  return false
end

--- Parse a notification and call the matching function.
--- Will return true if the notification was parsed successfully.
--- Will return false if the notification was not parsed successfully, 
--- or if the notification is not supported.
--- @param notification string The encoded notification to parse
--- @return boolean
function M.parse_notification(notification)
  -- Decode the notification
  local decoded = vim.fn.json_decode(notification)

  -- Ensure the notification was decoded
  if not decoded then
    return false
  end

  -- Match the notification and call proper functions
  if (decoded.notification == "client/connect") then
    notifications.connect_to_server(notification)
    return true
  end

  -- If the notification was not parsed, return false
  return false
end

--- Parse a response and call the matching function.
--- Will return true if the response was parsed successfully.
--- Will return false if the response was not parsed successfully, 
--- or if the response is not supported.
--- @param response string The encoded response to parse
--- @return boolean
function M.parse_response(response)
  -- Decode the notification
  local decoded = vim.fn.json_decode(responses)

  -- Ensure the notification was decoded
  if not decoded then
    return false
  end

  -- Match the notification and call proper functions
  if (decoded.notification == "server/connect") then
    responses.connect_to_server(response)
    return true
  end

  -- If the response was not parsed, return false
  return false
end

-- Return module
return M
