function table.keys(tab)
  local keys = {}
  for key, _ in pairs(tab) do
    keys[#keys + 1] = key
  end
  return keys
end

function table.key(tab, value)
  local keys = table.keys(tab)
  for _, key in ipairs(keys) do
    if tab[key] == value then
      return key
    end
  end
  return nil
end