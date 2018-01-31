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
  _perso.easings = {}
  
  _perso.moving = false
  
  _perso.map_start = map_start
  _perso.z = -10000
  
  _perso.falled = false
  
  _perso.update = function(dt)
    if (#_perso.easings < 1) then
      perso.moving = false
      return false
    else
      perso.moving = true
    end
    _perso.easings[1].update(_perso.pos)
    if (_perso.falled) then
      --print("_perso pos : ".._perso.pos.x..", ".._perso.pos.y)
    end
    if (not _perso.easings[1].moving) then
      _perso.pos.x = _perso.pos_goals[1].x
      _perso.pos.y = _perso.pos_goals[1].y
      _perso.line = _perso.easings[1].final_pos.line
      _perso.column = _perso.easings[1].final_pos.column
      table.remove(_perso.pos_goals, 1)
      table.remove(_perso.easings, 1)
      print("end !")
      if (#perso.pos_goals>0) then
        _perso.easings[1].startEase()
        if (_perso.easings[1].duration == 1000) then
          print("fall start !")
          _perso.falled = true
          perso_fall:stop()
          perso_fall:play()
        end
        _perso.moving = true
      end
    end
  end
  
  _perso.move = function()
    if (inScreen(_perso.line, _perso.column)) then
      if (_Perso.map.map_set[_perso.line][_perso.column] == 2) then
        move_stone:stop()
        move_stone:play()
      elseif (_Perso.map.map_set[_perso.line][_perso.column] == 4) then
        move_ice:stop()
        move_ice:play()
      else 
        move_grass:stop()
        move_grass:play()

      end
    end
    _perso.pos_goals[#_perso.pos_goals+1] = {x = 0, y = 0}
    _perso.pos_goals[#_perso.pos_goals] = _Perso.TabPos2Pos(perso.line, perso.column, _perso.tile_width, _perso.tile_height, _perso.pos_start)
    _perso.pos_goals[#_perso.pos_goals].x = _perso.pos_goals[#_perso.pos_goals].x+_perso.offset.x
    _perso.pos_goals[#_perso.pos_goals].y = _perso.pos_goals[#_perso.pos_goals].y+_perso.offset.y
    
    _perso.easings[#_perso.easings+1] = Ease.newEase(_perso.pos, _perso.pos_goals[#_perso.pos_goals], persoMovesEase, 75, _perso)
    _perso.easings[#_perso.easings].startEase()
    _perso.moving = true
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
      _perso.image = _perso.images.up
      _perso.scale_sign = 1
      local tmp_perso_pos = {line = _perso.line, column = _perso.column}
      _perso.line = _perso.line+1 
      _perso.move()
      local continuer = false
      if push_case then
        local pos_case = {line = _perso.line+1, column = _perso.column}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        
        while (continuer and inScreen(pos_case.line, pos_case.column)) do
          _perso.line = pos_case.line-1
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line+1, column = pos_case.column}
          if (not inScreen(pos_case.line, pos_case.column)) then
            break
          end
          if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
            continuer = true
          else
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
        
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
      local perso_next_pos = {line = tmp_perso_pos.line+1, column = tmp_perso_pos.column}
      continuer = false
      if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
        if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
          continuer = true
        end
      end
      
      while (continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) do
        _perso.line = perso_next_pos.line
        _perso.column = perso_next_pos.column
        _perso.move()
        perso_next_pos.line = perso_next_pos.line+1
        continuer = false
        if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
          if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
            continuer = true
          end
        end
        if (not continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) then
          _perso.line = perso_next_pos.line
          _perso.column = perso_next_pos.column
          _perso.move()
          local pose_case = {line = _perso.line+1, column = _perso.column}
          if (pMap.map_objects[_perso.line][_perso.column] == 6 or pMap.map_objects[_perso.line][_perso.column] == 7) then
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
        
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
    end
  end
  
  _perso.down = function(pMap, pObjects, pLvl) 
    can = true
    push_case = false
    
    if (pMap.map_objects[_perso.line-1][_perso.column] == 6 or pMap.map_objects[_perso.line-1][_perso.column] == 7) then
      push_case = true
      
      if _perso.line-2>_Perso.map.nb_tile_height then
        can = false
      elseif (pMap.map_objects[_perso.line-2][_perso.column] == 6 or pMap.map_objects[_perso.line-2][_perso.column] == 7) then
        can = false
      end
    end
    if (can) then
      _perso.image = _perso.images.up
      _perso.scale_sign = 1
      local tmp_perso_pos = {line = _perso.line, column = _perso.column}
      _perso.line = _perso.line-1 
      _perso.move()
      local continuer = false
      if push_case then
        local pos_case = {line = _perso.line-1, column = _perso.column}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        
        while (continuer and inScreen(pos_case.line, pos_case.column)) do
          _perso.line = pos_case.line-1
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line-1, column = pos_case.column}
          if (not inScreen(pos_case.line, pos_case.column)) then
            break
          end
          if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
            continuer = true
          else
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
        
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
      local perso_next_pos = {line = tmp_perso_pos.line-1, column = tmp_perso_pos.column}
      continuer = false
      if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
        if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
          continuer = true
        end
      end
      
      while (continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) do
        _perso.line = perso_next_pos.line
        _perso.column = perso_next_pos.column
        _perso.move()
        perso_next_pos.line = perso_next_pos.line-1
        continuer = false
        if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
          if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
            continuer = true
          end
        end
        if (not continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) then
          _perso.line = perso_next_pos.line
          _perso.column = perso_next_pos.column
          _perso.move()
          local pos_case = {line = _perso.line-1, column = _perso.column}
          if (pMap.map_objects[_perso.line][_perso.column] == 6 or pMap.map_objects[_perso.line][_perso.column] == 7) then
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
        
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
    end
  end
  
  _perso.right = function(pMap, pObjects, pLvl) 
    can = true
    push_case = false
    
    if (pMap.map_objects[_perso.line][_perso.column-1] == 6 or pMap.map_objects[_perso.line][_perso.column-1] == 7) then
      push_case = true
      
      if _perso.column-2>_Perso.map.nb_tile_width then
        can = false
      elseif (pMap.map_objects[_perso.line][_perso.column-2] == 6 or pMap.map_objects[_perso.line][_perso.column-2] == 7) then
        can = false
      end
    end
    if (can) then
      _perso.image = _perso.images.up
      _perso.scale_sign = 1
      local tmp_perso_pos = {line = _perso.line, column = _perso.column}
      _perso.column = _perso.column-1 
      _perso.move()
      local continuer = false
      if push_case then
        local pos_case = {line = _perso.line, column = _perso.column-1}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        
        while (continuer and inScreen(pos_case.line, pos_case.column)) do
          _perso.column = pos_case.column-1
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line, column = pos_case.column-1}
          if (not inScreen(pos_case.line, pos_case.column)) then
            break
          end
          if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
            continuer = true
          else
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
        
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
      local perso_next_pos = {line = tmp_perso_pos.line, column = tmp_perso_pos.column-1}
      continuer = false
      if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
        if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
          continuer = true
        end
      end
      
      while (continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) do
        _perso.line = perso_next_pos.line
        _perso.column = perso_next_pos.column
        _perso.move()
        perso_next_pos.column = perso_next_pos.column-1
        continuer = false
        if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
          if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
            continuer = true
          end
        end
        if (not continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) then
          _perso.line = perso_next_pos.line
          _perso.column = perso_next_pos.column
          _perso.move()
          local pose_case = {line = _perso.line, column = _perso.column-1}
          if (pMap.map_objects[_perso.line][_perso.column] == 6 or pMap.map_objects[_perso.line][_perso.column] == 7) then
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
        
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
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
      _perso.image = _perso.images.up
      _perso.scale_sign = 1
      local tmp_perso_pos = {line = _perso.line, column = _perso.column}
      _perso.column = _perso.column+1 
      _perso.move()
      local continuer = false
      if push_case then
        local pos_case = {line = _perso.line, column = _perso.column+1}
        if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
          continuer = true
        else
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
        end
        
        while (continuer and inScreen(pos_case.line, pos_case.column)) do
          _perso.column = pos_case.column+1
          _perso.push_case(pos_case, pMap, pObjects, pLvl)
          pos_case = {line = pos_case.line, column = pos_case.column+1}
          if (not inScreen(pos_case.line, pos_case.column)) then
            break
          end
          if (pMap.map_set[pos_case.line][pos_case.column] == 4) then
            continuer = true
          else
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
        
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
      local perso_next_pos = {line = tmp_perso_pos.line, column = tmp_perso_pos.column+1}
      continuer = false
      if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
        if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
          continuer = true
        end
      end
      
      while (continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) do
        _perso.line = perso_next_pos.line
        _perso.column = perso_next_pos.column
        _perso.move()
        perso_next_pos.column = perso_next_pos.column+1
        continuer = false
        if (inScreen(perso_next_pos.line, perso_next_pos.column)) then
          if (_Perso.map.map_set[perso_next_pos.line][perso_next_pos.column] == 4) then
            continuer = true
          end
        end
        if (not continuer and inScreen(perso_next_pos.line, perso_next_pos.column) and canPass(perso_next_pos, _perso.id)) then
          _perso.line = perso_next_pos.line
          _perso.column = perso_next_pos.column
          _perso.move()
          local pose_case = {line = _perso.line, column = _perso.column+1}
          if (pMap.map_objects[_perso.line][_perso.column] == 6 or pMap.map_objects[_perso.line][_perso.column] == 7) then
            _perso.push_case(pos_case, pMap, pObjects, pLvl)
          end
        end
      end
      
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
        
      _perso.line = tmp_perso_pos.line
      _perso.column = tmp_perso_pos.column
    end
  end
  
  _perso.push_case = function (pos_case, pMap, pObjects, pLvl) 
    local size = #pObjects
    print("push case #1")
    if (_Perso.map.map_objects[pos_case.line][pos_case.column] == 6 or _Perso.map.map_objects[pos_case.line][pos_case.column] == 7) then
      return false
    end
    local duration = 100
    if (_Perso.map.map_set[pos_case.line][pos_case.column] == 4) then
      duration = 400
    end
    for i = 1, size do
      if (pObjects[i].line == _perso.line and pObjects[i].column == _perso.column and (pObjects[i].id == 6 or pObjects[i].id == 7)) then
        if (pObjects[i].under ~= nil) then
          _perso.replace_under(pObjects, i, pLvl, pMap)
        end
        if (pMap.map_objects[pos_case.line][pos_case.column] ~= 0) then
          for j = 1, #pObjects do
            if pObjects[j] == nil then break end
            if (pObjects[j].line == pos_case.line and pObjects[j].column == pos_case.column) then
              if (not (pObjects[i].id == 6 and pObjects[j].id == 9) and (pObjects[j].id >= 8 and pObjects[j].id <= 11)) then
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
        local tmp_posgoal = _Perso.TabPos2Pos(pObjects[i].line, pObjects[i].column, pObjects[i].width, pObjects[i].height, _perso.pos_start)
        tmp_posgoal.x = tmp_posgoal.x-pObjects[i].width/2
        tmp_posgoal.y = tmp_posgoal.y-pObjects[i].height/2
        if (pMap.map_objects[pos_case.line][pos_case.column] == 9 and pObjects[i].id == 6) then
          tmp_posgoal.y = tmp_posgoal.y-15
        end
        
        if (pMap.map_set[pos_case.line][pos_case.column] == 3 and pObjects[i].id == 6)then
          if (pMap.map_objects[_perso.line][_perso.column] == pObjects[i].id) then
            pMap.map_objects[_perso.line][_perso.column] = 0
          end
          pObjects[i].id = 12
          pObjects[i].image = pMap.tile_set[12].image
          pMap.map_set[pos_case.line][pos_case.column] = -1
          plouf:play()
        elseif (pMap.map_set[pos_case.line][pos_case.column] == 3 and pObjects[i].id == 7)then
          if (pMap.map_objects[_perso.line][_perso.column] == pObjects[i].id) then
            pMap.map_objects[_perso.line][_perso.column] = 0
          end
          table.remove(pObjects, i)
          size = size-1
          plouf:play()
          break
        end
        if (pMap.map_set[pos_case.line][pos_case.column] == 0) then
          pObjects[i].setMoving(tmp_posgoal, duration)
          pObjects[i].fall()
        else
          pObjects[i].setMoving(tmp_posgoal, duration)
        end
        move_box:stop()
        move_box:play()
        
        pMap.map_objects[pos_case.line][pos_case.column] = pObjects[i].id
        if (pMap.map_objects[_perso.line][_perso.column] == pObjects[i].id)then pMap.map_objects[_perso.line][_perso.column] = 0 end
        break
      end
    end
  end
  
  _perso.fall = function(type_fall)
    print("fall !")
    _perso.moving = false
    _perso.move()
    local coeff = 110
    
    if (type_fall == "hole") then
      coeff = 110
    end
    if (type_fall == "border")then 
      if (_perso.line > _Perso.map.nb_tile_height or _perso.column > _Perso.map.nb_tile_width)then
        coeff = -10000
      end
    end
   
    _perso.z = _perso.map_start.y-(_perso.pos_goals[#_perso.pos_goals].y*0.1*_Tile.scale.y)-coeff 
      
    _perso.pos_goals[#_perso.pos_goals+1] = {x = _perso.pos_goals[#_perso.pos_goals].x, y = _perso.pos_goals[#_perso.pos_goals].y+1000}
    print("before : "..#_perso.easings)
    _perso.easings[#_perso.easings+1] = Ease.newEase(_perso.pos_goals[#_perso.pos_goals-1], _perso.pos_goals[#_perso.pos_goals], persoFallEase, 1000, _perso.easings[#_perso.easings].final_pos)
    _perso.moving = true
    
    
  end
  
  _perso.replace_under = function(pObjects, i, pLvl, pMap)
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