_Tile = {}
_Tile.tile_width = 32
_Tile.tile_height = 32
_Tile.pattern = {width = 1, height = 1}
_Tile.scale = {x = 1, y = 1}
_Tile.tile_set = {}

_Tile.newTile = function(pLine, pColumn, pPos, pTile_base_pattern)
  local _tile = {}
  _tile.name = ""
  _tile.pos = {x = pPos.x, y = pPos.y}
  _tile.image = pTile_base_pattern.image

  _tile.width = _tile.image:getWidth()
  _tile.height = _tile.image:getHeight()
  
  _tile.line = pLine
  _tile.column = pColumn
  
  _tile.id = pTile_base_pattern.id
  
  _tile.under = nil
  
  _tile.isunder = false
  
  _tile.map_start = {x = 0, y = 0}
  
  if (_tile.id <=5) then
    _Tile.tile_width = _tile.width
    _Tile.tile_height = _tile.height
  end  
  
  _tile.pos_goal = {x = 0, y = 0}
  
  _tile.moving = false
  _tile.ease = {start = {x = 0, y = 0}, start_time = 0, time = 0, offset = {x = 0, y = 0}, duration = 100, fct = persoMovesEase}
  
  _tile.offset = {x = 0, y = 0}
  
  _tile.object_inhole = false
  
  _tile.inhole = {exist = false}
  _tile.exist = true
  _tile.z = 0
  
  
  _tile.falled = false
  _tile.update_z = function()
    _tile.z = _tile.map_start.y-(_tile.pos.y*0.1*_Tile.scale.y)
    if (_Tile.isBox(_tile.id) or _tile.id == 12) then
      _tile.z = _tile.map_start.y-(_tile.pos.y*0.1*_Tile.scale.y)-15
    end
  end
  _tile.update = function(map_start)
    if (not _tile.falled)then
      _tile.update_z(map_start)
    end
    if (_tile.moving) then
      if _tile.pos.x~=_tile.pos_goal.x or _tile.pos.y~=_tile.pos_goal.y then
        _tile.ease.time = socket.gettime()*1000
        _tile.ease.time = _tile.ease.time-_tile.ease.start_time
        
        _tile.pos.x = _tile.ease.fct(_tile.ease.time, _tile.ease.start.x, _tile.ease.offset.x, _tile.ease.duration)
        _tile.pos.y = _tile.ease.fct(_tile.ease.time, _tile.ease.start.y, _tile.ease.offset.y, _tile.ease.duration)
        
        if (_tile.ease.time>=_tile.ease.duration) then
          _tile.pos.x = _tile.pos_goal.x
          _tile.pos.y = _tile.pos_goal.y
        end
      else 
        _tile.moving = false
      end
    end
  end
  
  _tile.setMoving = function(pPosGoal, pDuration, pFct)
    if (true) then
      if (pDuration ~= nil) then
        _tile.ease.duration = pDuration
      else
        _tile.ease.duration = 100
      end
      if (pFct ~= nil) then
        _tile.ease.fct = pFct
      else
        _tile.ease.fct = persoMovesEase
      end
      
      _tile.moving = true
      _tile.pos_goal.x = pPosGoal.x+_tile.offset.x
      _tile.pos_goal.y = pPosGoal.y+_tile.offset.y
      
      _tile.ease.start.x = _tile.pos.x
      _tile.ease.start.y = _tile.pos.y
      _tile.ease.start_time = socket.gettime()*1000
      _tile.ease.time = 0
      _tile.ease.offset.x = _tile.pos_goal.x-_tile.pos.x
      _tile.ease.offset.y = _tile.pos_goal.y-_tile.pos.y
    end
  end
  
  _tile.fall = function()
    _tile.falled = true
    _tile.moving = false
    _tile.pos.x = _tile.pos_goal.x
    _tile.pos.y = _tile.pos_goal.y
    _tile.setMoving({x = _tile.pos.x, y = _tile.pos.y + height+100}, 1000, Tile.fallEase)
    _tile.update_z(map_start)
    print("_tile.z".._tile.z)
  end
  
  return _tile
end


_Tile.newTileBase = function(pPath_img_tile, pTile_id)
  local _tile_base = {}
  _tile_base.image = love.graphics.newImage(pPath_img_tile)
  _tile_base.id = pTile_id
  
  return _tile_base
end

_Tile.initTiles = function(pMapSet, pTiles, pNbTileWidth, pNbTileHeight, pTiledPattern)
  local pos_start = {x = 0, y = 0}
  local pos_x = pos_start.x
  local pos_y = pos_start.y
  local pos = {x = pos_start.x, y = pos_start.y}
  
  _Tile.pattern.width = pTiledPattern.width
  _Tile.pattern.height = pTiledPattern.height
  
  local index = 1
  
  print("type : "..type(pMapSet))
  
  for i = 0,pNbTileHeight-1 do
    for j = 0,pNbTileWidth-1 do
      if (pMapSet[i+1][j+1] ~= 0) then
        pos.x = pos_x-(j*(pTiledPattern.width/2))
        pos.y = pos_y-(j*(pTiledPattern.height/2))
        pattern_height = pTiledPattern.height
        pattern_width = pTiledPattern.width
        print("pTiles[index] : "..type(pTiles[index]))
        pTiles[index].pos.x = pos.x
        pTiles[index].pos.y = pos.y
        index = index+1
      end
    end
    pos_x = pos_x+(pTiledPattern.width/2)
    pos_y = pos_y-(pTiledPattern.height/2)
  end
  
  table.sort( pTiles, 
    function (a, b) 
      return a.pos.y<b.pos.y
    end
  )
  
  return pos_start
end

_Tile.initObjects = function(pTiles, pNbTileWidth, pNbTileHeight, pFct, pMapObjects, pPosStart)
  index = 1
  for i = 1,pNbTileHeight do
    for j = 1,pNbTileWidth do
      if (pMapObjects[i][j] ~= 0) then
        pTiles[index].pos = pFct(i, j, pTiles[index].width, pTiles[index].height, pPosStart)
        pTiles[index].pos.x = pTiles[index].pos.x-pTiles[index].width/2
        pTiles[index].pos.y = pTiles[index].pos.y-pTiles[index].height/2
        pTiles[index].offset.x = -_Tile.tile_width*0.2*Tile.scale.x
        pTiles[index].offset.y = -_Tile.tile_height*1.1*_Tile.scale.y
        if (pTiles[index].id >= 8 and pTiles[index].id <=11) then
          pTiles[index].offset.x = pTiles[index].offset.x+_Tile.tile_width/2-19
          pTiles[index].offset.y = pTiles[index].offset.y+_Tile.tile_height/2+11
        end
        pTiles[index].pos.x = pTiles[index].pos.x + pTiles[index].offset.x
        pTiles[index].pos.y = pTiles[index].pos.y + pTiles[index].offset.y
        index = index+1
      end
    end
  end
  
  if (#pTiles>1) then
    table.sort( pTiles, 
      function (a, b) 
        return a.pos.y<b.pos.y
      end
    )
  end
  
end

_Tile.fallEase = function(t, b, c, d)
  local t = t/d;
	return c*t*t*t + b;
end

_Tile.setScale = function(x, y)
  Tile.scale.x = x
  Tile.scale.y = y
end

function boxMovesEase(t, b, c, d)
	t = t/d;
	return c*t*t*t + b;
end

_Tile.init = function(table, tile)
	local images = {
				"images/ground/grass.png", --tiles
				"images/ground/stone.png",
				"images/ground/water.png",
				"images/ground/ice.png",
				"images/ground/hole.png",
				"images/box_wood.png", --object
				"images/box_stone.png",
				"images/button_stone_on.png",
				"images/button_stone_off.png",
				"images/button_wood_on.png",
				"images/button_wood_off.png",
        "images/box_wood_floating.png",
        "images/box_stone_floating.png"
			}
	for i=1, #images do -- chargement des images
		table[i] = tile.newTileBase( images[i], i)
    _Tile.tile_set[i] = tile.newTileBase( images[i], i)
	end
	
	
end

_Tile.isBox = function(id)
  return id == 6 or id == 7
end

_Tile.isPerso = function(id)
  return id == 1000000
end

_Tile.isButton = function(id)
  return id >= 8 and id <= 11
end

_Tile.isTileGround = function(id)
  return id >= 1 and id <= 5
end

_Tile.isObject = function(id)
  return (id > 5 and id <= #_Tile.tile_set) or _Tile.isPerso(id)
end

return _Tile