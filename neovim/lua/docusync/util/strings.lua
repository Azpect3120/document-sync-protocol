local M = {}

--- Split a string by a separator.
--- @param str string
--- @param sep string
--- @return table
function M.split(str, sep)
  local result = {}
  for match in (str.. sep):gmatch("(.-)" .. sep) do
    table.insert(result, match)
  end
  return result
end

--- Trim whitespace from a string.
--- @param str string
--- @return string
function M.trim(str)
  return str:match("^%s*(.-)%s*$")
end

return M
