_pause = {
    enable = false
}


function _pause:ingame(key)
   
      if key == "return"  then
        if _pause.enable == false then
        _pause.enable = true
        else
        _pause.enable = false            
        end
      end
      



end

function _pause:draw()

end


return _pause