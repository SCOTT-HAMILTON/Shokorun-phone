local _Ease = {}

_Ease.newEase = function(pStartPos, pEndPos, pFctEase, pDuration, pFinalPos)
  local _ease =  {}
  _ease.start_pos = {x = 0, y = 0}
  _ease.start_pos.x = pStartPos.x
  _ease.start_pos.y = pStartPos.y
  _ease.start_time = 0
  _ease.time = 0
  _ease.offset = {x = 0, y = 0}
  _ease.offset.x = pEndPos.x-pStartPos.x
  _ease.offset.y = pEndPos.y-pStartPos.y
  _ease.duration = pDuration
  _ease.fct = pFctEase
  _ease.moving = false
  _ease.final_pos = {line = pFinalPos.line, column = pFinalPos.column}
  
  _ease.update = function(pPos)
    _ease.time = socket.gettime()*1000
    pPos.x = _ease.fct(_ease.time-_ease.start_time, _ease.start_pos.x, _ease.offset.x, _ease.duration)
    pPos.y = _ease.fct(_ease.time-_ease.start_time, _ease.start_pos.y, _ease.offset.y, _ease.duration)
    
    if (_ease.time-_ease.start_time>=_ease.duration) then
      _ease.moving = false
    end
  end
  
  _ease.startEase = function(pDuration, pFctEase)
    _ease.moving = true
    _ease.start_time = socket.gettime()*1000
  end
  
  return _ease
end

return _Ease