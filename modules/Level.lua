_Level = {}
_Level.index_level = 1
_Level.levels = {}

local dir = "/level"
_Level.lvlFiles = love.filesystem.getDirectoryItems(dir)

for i = 1, #_Level.lvlFiles -1 do
	table.insert(_Level.levels, require("../level/lvl_"..i))
end


_Level.current_level = _Level.levels[_Level.index_level]

_Level.goToNextLevel = function()
  _Level.index_level = _Level.index_level+1
  if _Level.index_level>#_Level.levels then
    _Level.index_level = 1
  end
  
  _Level.current_level = _Level.levels[_Level.index_level]
end

return _Level