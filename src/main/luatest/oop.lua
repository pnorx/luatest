--- Funktionen zum Umgang mit Klassen(-strukturen).
-- @module oop

--- Erzeuge eine neue Klasse.
-- 
-- @tparam string classname Name der neuen Klasse (wird z.B. von subtype() zurückgegeben)
-- @tparam class superclass Eine Basisklasse, von der geerbt werden soll
class = function(classname, superclass)
  assert(type(classname) == "string")

  local new_class = {}
  new_class.__type = {__index = new_class}
  new_class.__tostring = function() return classname end
  if superclass then
    assert(isclass(superclass))
    new_class.__index = superclass
    -- the standard constructor executes the constructor of the superclass
    new_class.__call = function(self, ...) return setmetatable(superclass(...), self.__type) end
    -- copy all metaevent-handlers e.g. to do tostring(instance)
    for metaevent, handler in pairs(superclass.__type) do new_class.__type[metaevent] = handler end
    -- override the index-event with the new class
    new_class.__type.__index = new_class
  else
    new_class.__call = function(self) return setmetatable({}, self.__type) end
  end
  setmetatable(new_class, new_class)
  return new_class
end

--- Prüft, ob Variable eine Klasse ist.
-- 
-- @param classref Variable, die geprüft werden soll
isclass = function(classref)
  if type(classref) == "table" then -- Eine Klasse muss immer eine table sein
    if classref == getmetatable(classref) then -- Eine Klasse hat immer sich selbst als metatable
      if type(classref.__type) == "table" then -- Eine Klasse hat immer ein __type-Feld, dass das Verhalten von Instanzen bestimmt
        if classref.__type.__index == classref then -- Das __index-Feld von __type zeigt immer auf die Klassen-Tabelle
          if type(classref.__tostring) == "function" then -- Eine Klasse hat immer eine tostring-Funktion...
            if type(classref.__tostring()) == "string" then -- die einen string zurückgibt, um die Klasse zu identifizieren
              if type(classref.__call) == "function" then -- Eine Klasse hat immer einen Konstruktor
                -- WICHTIG!: Der Konstruktor sollte eine table mit der classref.__type-table als metatable zurückgeben
                return true
              end
            end
          end
        end
      end
    end
  end
  return false
end

--- Gibt den Typ einer Variable zurück (beachtet Klassen(-strukturen))
-- 
-- @param var Variable, dessen Type bestimmt werden soll
subtype = function(var)
  if type(var) == "table" then
    if isclass(var) then
      return "class"
    else
      local metatable = getmetatable(var)
      if metatable then
        if type(metatable.__index) == "table" then
          if isclass(metatable.__index) then
            return tostring(metatable.__index)
          end
        end
      end
    end
  end
  return type(var)
end

--- Gibt die Klassenhierarchie einer Variablen zurück
-- 
-- @param var Variable, dessen Klassenhierarchie bestimmt werden soll
hierarchy = function(var)
  local hierarchy_list = {}
  if type(var) == "table" then
    local typetable = getmetatable(var)
    if typetable then
      while(type(typetable.__index) == "table") do
        hierarchy_list[#hierarchy_list + 1] = typetable.__index
        typetable = typetable.__index
      end
    end
  end
  return hierarchy_list
end

--- Prüft den (Sub-)Typ einer Variable.
-- 
-- @param instance Variable, die gegen einen Typ geprüft werden soll
-- @tparam class|string typeref Typ, gegen den die Variable geprüft werden soll
isinstance = function(instance, typeref)
  if type(typeref) == "table" then
    -- Table als typeref macht nur Sinn, wenn die table eine Klasse ist
    if isclass(typeref) then
      local instance_hierarchy = hierarchy(instance)
      for i, parent in ipairs(instance_hierarchy) do
      -- Teste auf Instanz einer Klasse
        if typeref == parent then return true end
      end
    else
      error("Invalid typeref is table but not a class")
    end
  elseif type(typeref) == "string" then
    return subtype(instance) == typeref -- TODO: check if subtype is correct
  else
    error("Invalid typeref is neither table nor string")
  end
end
