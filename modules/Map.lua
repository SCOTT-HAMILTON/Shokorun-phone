local _Map = {}

_Map.newMap = function(pMapSet, pMapObjects , pTileSet) 
  local _map = {}
  _map.nb_tile_height = #pMapSet
  _map.nb_tile_width = #pMapSet[1]
  
  _map.map_set = {}
  _map.map_objects = {}
  
  _map.pos_start = {x = 0, y = 0}
  
  for i = 1, _map.nb_tile_height do
    _map.map_set[i] = {}
    _map.map_objects[i] = {}
      for j = 1, _map.nb_tile_width do
        _map.map_set[i][j] = pMapSet[i][j]
        _map.map_objects[i][j] = pMapObjects[i][j]
      end
  end
  
  _map.tile_set = {}
  for i = 1, #pTileSet do
    _map.tile_set[i] = pTileSet[i]
  end
  
  return _map
end

return _Map