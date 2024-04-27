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

return M
