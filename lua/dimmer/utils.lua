local M = {}

function M.table_find(haystack, needle)
  for _, val in ipairs(haystack) do
    if val == needle then
      return true
    end
  end
  return false
end

function M.set(table)
  local ret = {}
  for _, key in ipairs(table) do
    ret[key] = true
  end
  return ret
end

return M
