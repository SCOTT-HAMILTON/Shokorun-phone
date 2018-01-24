require ("socket")

_Perso = {}
_Perso.map = nil

_Perso.newPerso = function(map_start, pLine, pColumn, pPathImages, p_Tile, pos_start) 
  local _perso = {}
  _perso.name = "perso"
  _perso.line = pLine
  _perso.column = pColumn
  _perso.tile_width = p_Tile.tile_width
  _perso.tile_height = p_Tile.tile_height
  _perso.images = {}
  _perso.images.up = love.graphics.newImage(pPathImages.up)
  _perso.images.down = love.graphics.newImage(pPathImages.down)
  _perso.image = _perso.images.up
  _perso.pos_start = {x = pos_start.x, y = pos_start.y}
  _perso.id = 1000000
  _perso.offset = {x = 0, y = 0}
  _perso.offset.y = -_perso.image:getHeight()*p_Tile.scale.x-p_Tile.tile_height*0.7*p_Tile.scale.y
  _perso.offset.x = -p_Tile.tile_width*0.3*p_Tile.scale.x
  
  _perso.scale_sign = 1
  
  _perso.pos = {x = 0, y = 0}
  _perso.pos = _Perso.TabPos2Pos(_perso.line, _perso.column, _perso.tile_width, _perso.tile_height, _perso.pos_start)
  _perso.pos.x = _perso.pos.x+_perso.offset.x
  _perso.pos.y = _perso.pos.y+_perso.offset.y
  
  _perso.pos_goals = {}
  
  _perso.moving = false
  _perso.ease = {start = {x = 0, y = 0}, start_time = 0, time = 0, offset = {x = 0, y = 0}, duration = 50, fct = persoMovesEase}
  
  _perso.map_start = map_start
  _perso.tmp_co = _perso.image:getHeight()*0.5*p_Tile.scale.y
  _perso.z = _perso.map_start.y-(_perso.pos.y+_perso.tmp_co)
  
  _perso.falled = false
  
  _perso.update = function(dt)
    if (not _perso.falled) then _perso.z = _perso.map_start.y-(_perso.pos.y+_perso.tmp_co) end
    if (_perso.moving) then
      if (#_perso.pos_goals < 1) then
        perso.moving = false
        return false
      else
        perso.moving = true
      end
      if _perso.pos.x~=_perso.pos_goals[1].x or _perso.pos.y~=_perso.pos_goals[1].y then
        _perso.ease.time = socket.gettime()*1000
        _perso.ease.time = _perso.ease.time-_perso.ease.start_time
        
        _perso.pos.x = _perso.ease.fct(_perso.ease.time, _perso.ease.start.x, _perso.ease.offset.x, _perso.ease.duration)
        _perso.pos.y = _perso.ease.fct(_perso.ease.time, _perso.ease.start.y, _perso.ease.offset.y, _perso.ease.duration)
        if (_perso.ease.time>=_perso.ease.duration) then
          _perso.pos.x = _perso.pos_goals[1].x
          _perso.pos.y = _perso.pos_goals[1].y
          if (#_perso.pos_goals>0)then
            table.remove(_perso.pos_goals, 1)
          end
          if (#perso.pos_goals>0) then
            _perso.moving = true
            _perso.moving = true
            
            _perso.ease.start.x = _perso.pos.x
            _perso.ease.start.y = _perso.pos.y
            _perso.ease.start_time = socket.gettime()*1000
            _perso.ease.time = 0
            _perso.ease.offset.x = _perso.pos_goals[1].x-_perso.pos.x
            _perso.ease.offset.y = _perso.pos_goals[1].y-_perso.pos.y
          end
        end
      end
    end
  end
  
  _perso.move = function() 
    _perso.pos_goals[#_perso.pos_goals+1] = {x = 0, y = 0}
    _perso.pos_goals[#_perso.pos_goals] = _Perso.TabPos2Pos(perso.line, perso.column, _perso.tile_width, _perso.tile_height, _perso.pos_start)
    _perso.pos_goals[#_perso.pos_goals].x = _perso.pos_goals[#_perso.pos_goals].x+_perso.offset.x
    _perso.pos_goals[#_perso.pos_goals].y = _perso.pos_goals[#_perso.pos_goals].y+_perso.offset.y
    _perso.moving = true
    
    _perso.ease.start.x = _perso.pos.x
    _perso.ease.start.y = _perso.pos.y
    _perso.ease.start_time = socket.gettime()*1000
    _perso.ease.time = 0
    _perso.ease.offset.x = _perso.pos_goals[#_perso.pos_goals].x-_perso.pos.x
    _perso.ease.offset.y = _perso.pos_goals[#_perso.pos_goals].y-_perso.pos.y
      
  end
  
  _perso.up = function(pMap, pObjects, pLvl) 
    can = true
    push_case = false
    
    if (pMap.map_objects[_perso.line+1][_perso.column] == 6 or pMap.map_objects[_perso.line+1][_perso.column] == 7) then
      push_case = true
      if _perso.line+2>_Perso.map.nb_tile_height then
        can = false
      elseif (pMap.map_objects[_perso.line+2][_perso.column] == 6 or pMap.map_objects[_perso.line+2][_perso.column] == 7) then
        can = false
      end
    end
    if (can) then
      _perso.line = _perso.line+1 
      _perso.image = _perso.images.up
      _perso.scale_sign = 1
       
      _perso.move()
       local continuer = false
      if push_case then
        local pos_case = {line = _perso.line+1, column = _perso.column}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        local tmp_perso_pos = {line = _perso.line, column = _perso.column}
        while (continuer) do
          if (pMap.map_set[pos_case.line][pos_case.column] ~= 4) then continuer = false end
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line+1, column = pos_case.column}
          _perso.line = _perso.line+1
          if (pos_case.line<=map.nb_tile_height and pos_case.line>=1 and pos_case.column<=map.nb_tile_width and pos_case.column>=1) then
            if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
              continuer = true
            end
          else
            continuer = false
          end
        end
        _perso.line = tmp_perso_pos.line
        _perso.column = tmp_perso_pos.column
      end
    end
  end
  
  _perso.down = function(pMap, pObjects, pLvl) 
    can = true
    push_case = false
    if (pMap.map_objects[_perso.line-1][_perso.column] == 6 or pMap.map_objects[_perso.line-1][_perso.column] == 7) then
      push_case = true
      if _perso.line-2<1 then
        can = false
      elseif (pMap.map_objects[_perso.line-2][_perso.column] == 6 or pMap.map_objects[_perso.line-2][_perso.column] == 7) then
        can = false
      end
    end
    if (can) then
      _perso.line = _perso.line-1 
      _perso.scale_sign = -1
      _perso.image = _perso.images.down
      
      _perso.move()
      
      if push_case then
        local pos_case = {line = _perso.line-1, column = _perso.column}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        local tmp_perso_pos = {line = _perso.line, column = _perso.column}
        while (continuer) do
          if (pMap.map_set[pos_case.line][pos_case.column] ~= 4) then continuer = false end
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line-1, column = pos_case.column}
          _perso.line = _perso.line-1
          if (pos_case.line<=map.nb_tile_height and pos_case.line>=1 and pos_case.column<=map.nb_tile_width and pos_case.column>=1) then
            if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
              continuer = true
            end
          else
            continuer = false
          end
        end
        _perso.line = tmp_perso_pos.line
        _perso.column = tmp_perso_pos.column
      end
    end
  end
  
  _perso.right = function(pMap, pObjects, pLvl) 
    can = true
    push_case = false
    if (pMap.map_objects[_perso.line][_perso.column-1] == 6 or pMap.map_objects[_perso.line][_perso.column-1] == 7) then
      push_case = true
      if _perso.column-2<1 then
        can = false
      elseif (pMap.map_objects[_perso.line][_perso.column-2] == 6 or pMap.map_objects[_perso.line][_perso.column-2] == 7) then
        can = false
      end
    end
    if (can) then
      _perso.column = _perso.column-1
      _perso.scale_sign = 1
      _perso.image = _perso.images.down
      
      _perso.move()
      
      if push_case then
        local pos_case = {line = _perso.line, column = _perso.column-1}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        local tmp_perso_pos = {line = _perso.line, column = _perso.column}
        while (continuer) do
          if (pMap.map_set[pos_case.line][pos_case.column] ~= 4) then continuer = false end
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line, column = pos_case.column-1}
          _perso.column = _perso.column-1
          if (pos_case.line<=map.nb_tile_height and pos_case.line>=1 and pos_case.column<=map.nb_tile_width and pos_case.column>=1) then
            if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
              continuer = true
            end
          else
            continuer = false
          end
        end
        _perso.line = tmp_perso_pos.line
        _perso.column = tmp_perso_pos.column
      end
    end
  end
  
  _perso.left = function(pMap, pObjects, pLvl)
    can = true
    push_case = false
    if (pMap.map_objects[_perso.line][_perso.column+1] == 6 or pMap.map_objects[_perso.line][_perso.column+1] == 7) then
      push_case = true
      if _perso.column+2>_Perso.map.nb_tile_width then
        can = false
      elseif (pMap.map_objects[_perso.line][_perso.column+2] == 6 or pMap.map_objects[_perso.line][_perso.column+2] == 7) then
        can = false
      end
    end
    if (can) then
      _perso.column = _perso.column+1
      _perso.scale_sign = -1
      _perso.image = _perso.images.up
      
      _perso.move()
      
      if push_case then
        local pos_case = {line = _perso.line, column = _perso.column+1}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        local tmp_perso_pos = {line = _perso.line, column = _perso.column}
        while (continuer) do
          if (pMap.map_set[pos_case.line][pos_case.column] ~= 4) then continuer = false end
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line, column = pos_case.column+1}
          _perso.column = _perso.column+1
          if (pos_case.line<=map.nb_tile_height and pos_case.line>=1 and pos_case.column<=map.nb_tile_width and pos_case.column>=1) then
            if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
              continuer = true
            end
          else
            continuer = false
          end
        end
        _perso.line = tmp_perso_pos.line
        _perso.column = tmp_perso_pos.column
      end
    end
  end
  
  _perso.push_case = function (pos_case, pMap, pObjects, pLvl) 
    local size = #pObjects
    print("yeah : "..pos_case.line..", "..pos_case.column)
    for i = 1, size do
      if (pObjects[i].line == _perso.line and pObjects[i].column == _perso.column and (pObjects[i].id == 6 or pObjects[i].id == 7)) then
        if (pObjects[i].under ~= nil) then
          if (pObjects[i].under.id >= 8 and pObjects[i].under.id <= 11) then
            if (not (pObjects[i].id == 6 and pObjects[i].under.id == 9)) then
              pLvl.nb_buttons_succed = pLvl.nb_buttons_succed-1
            end
          end
          pObjects[i].under.isunder = false
          pObjects[#pObjects+1] = pObjects[i].under
          pMap.map_objects[_perso.line][_perso.column] = pObjects[i].under.id
          pObjects[i].under = nil
        end
        if (pMap.map_objects[pos_case.line][pos_case.column] ~= 0) then
          for j = 1, #pObjects do
            if pObjects[j] == nil then break end
            if (pObjects[j].line == pos_case.line and pObjects[j].column == pos_case.column) then
              if (not (pObjects[i].id == 6 and pObjects[j].id == 9)) then
                pLvl.nb_buttons_succed = pLvl.nb_buttons_succed+1
              end
              pObjects[i].under = pObjects[j]
              pObjects[i].under.isunder = true
              table.remove(pObjects, j)
              size = size-1
              break
            end
          end
        end
        
        for l = 1, size do
          if (pObjects[l].line == _perso.line and pObjects[l].column == _perso.column and (pObjects[l].id == 6 or pObjects[l].id == 7)) then
            i = l
            break
          end
        end
        if (pObjects[i] == nil) then break end
        
        pObjects[i].line = pos_case.line
        pObjects[i].column = pos_case.column
        print("pObjects[i].line, pObjects[i].column ! "..pObjects[i].line..", "..pObjects[i].column)
        local tmp_posgoal = _Perso.TabPos2Pos(pObjects[i].line, pObjects[i].column, pObjects[i].width, pObjects[i].height, _perso.pos_start)
        tmp_posgoal.x = tmp_posgoal.x-pObjects[i].width/2
        tmp_posgoal.y = tmp_posgoal.y-pObjects[i].height/2
        if (pMap.map_objects[pos_case.line][pos_case.column] == 9 and pObjects[i].id == 6) then
          tmp_posgoal.y = tmp_posgoal.y-15
        end
        
        if (pMap.map_set[pos_case.line][pos_case.column] == 3 and pObjects[i].id == 6)then
          pObjects[i].id = 12
          pObjects[i].image = pMap.tile_set[12].image
        elseif (pMap.map_set[pos_case.line][pos_case.column] == 3 and pObjects[i].id == 7)then
          pObjects[i].id = 13
          pObjects[i].image = pMap.tile_set[13].image
        end
        if (pMap.map_set[pos_case.line][pos_case.column] == 0) then
          pObjects[i].setMoving(tmp_posgoal)
          pObjects[i].fall()
        else
          pObjects[i].setMoving(tmp_posgoal)
        end
        
        pMap.map_objects[pos_case.line][pos_case.column] = pObjects[i].id
        if (pMap.map_objects[_perso.line][_perso.column] == pObjects[i].id)then pMap.map_objects[_perso.line][_perso.column] = 0 end
        break
      end
    end
  end
  
  _perso.fall = function()
    _perso.falled = true
    _perso.moving = false
    _perso.move()
    perso.z = _perso.map_start.y-(_perso.pos_goals[#_perso.pos_goals].y+_perso.tmp_co)
    _perso.pos_goals[#_perso.pos_goals].y = _perso.pos_goals[#_perso.pos_goals].y+1000
    _perso.ease.duration = 2000
    _perso.ease.fct = persoFallEase
    _perso.ease.offset.x = _perso.pos_goals[#_perso.pos_goals].x-_perso.pos.x
    _perso.ease.offset.y = _perso.pos_goals[#_perso.pos_goals].y-_perso.pos.y
  end
  
  return _perso
end

_Perso.TabPos2Pos = function(line, column, tile_width, tile_height, pPosStart)
  local _pos = {x = 0, y = 0}
  _pos.x = pPosStart.x+tile_width/2
  _pos.y = pPosStart.y+tile_height/2
  
  _pos.y = _pos.y-( ((line+column)/2-1)*Tile.pattern.height )
  
  if (column>line) then
    _pos.x = _pos.x-((column-line)*(Tile.pattern.width/2))
  elseif (column<line) then
    _pos.x = _pos.x+((line-column)*(Tile.pattern.width/2))
  end
  
  return _pos
end


function persoMovesEase(t, b, c, d)
	local t = t/d
	return -c * t*(t-2) + b;
end

function persoFallEase(t, b, c, d)
  local t = t/d;
	return c*t*t*t + b;
end

return _Perso