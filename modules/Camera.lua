_Camera = {}

_Camera.newCamera = function()
  _camera = {}
  
  _camera.pos = {x = 0, y = 0}
  _camera.pos_goal = {x = 0, y = 0}
  _camera.moving = false
  _camera.ease = {start = {x = 0, y = 0}, start_time = 0, time = 0, offset = {x = 0, y = 0}, duration = 250}
  
  _camera.update = function()
    if (_camera.moving) then
      if _camera.pos.x~=_camera.pos_goal.x or _camera.pos.y~=_camera.pos_goal.y then
        _camera.ease.time = socket.gettime()*1000
        _camera.ease.time = _camera.ease.time-_camera.ease.start_time
        
        _camera.pos.x = cameraMovesEase(_camera.ease.time, _camera.ease.start.x, _camera.ease.offset.x, _camera.ease.duration)
        _camera.pos.y = cameraMovesEase(_camera.ease.time, _camera.ease.start.y, _camera.ease.offset.y, _camera.ease.duration)
        
        if (_camera.ease.time>=_camera.ease.duration) then
          _camera.pos.x = _camera.pos_goal.x
          _camera.pos.y = _camera.pos_goal.y
        end
      else 
        _camera.moving = false
      end
    end
  end
  
  _camera.setMoving = function(pPosGoal)
    if (not _camera.moving) then
      _camera.moving = true
      _camera.pos_goal.x = pPosGoal.x
      _camera.pos_goal.y = pPosGoal.y
      
      _camera.ease.start.x = _camera.pos.x
      _camera.ease.start.y = _camera.pos.y
      _camera.ease.start_time = socket.gettime()*1000
      _camera.ease.time = 0
      _camera.ease.offset.x = _camera.pos_goal.x-_camera.pos.x
      _camera.ease.offset.y = _camera.pos_goal.y-_camera.pos.y
      
    end
  end
  
  return _camera
end

function cameraMovesEase (t, b, c, d)
	return c*t/d + b;
end

return _Camera