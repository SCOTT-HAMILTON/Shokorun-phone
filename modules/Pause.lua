_pause = {
    enable = false,
    width = 250,
    height = 300,
    showMenu= {},
	  menuSelect = 1,
    posY = 30
}

local bg_image = love.graphics.newImage( "images/ui/pause/pause.png" )


local menu = {
	{"Restart", "Main Menu", "Exit Game"},
	--Option = {"SFX", "Music", "Reset", "Back"}
	}

function _pause:load()
  _pause.showMenu = menu[1]
end

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
  if _pause.enable == true then
    love.graphics.setColor(127,127,127, 150)
      love.graphics.rectangle("fill",0, 0, love.graphics.getWidth() ,love.graphics.getHeight())

    love.graphics.setColor(255,255,255,255)
    love.graphics.draw(bg_image,  (love.graphics.getWidth() - _pause.width)/2, (love.graphics.getHeight() - _pause.height) /2)
    --love.graphics.rectangle("fill", (love.graphics.getWidth() - _pause.width)/2, (love.graphics.getHeight() - _pause.height) /2, _pause.width, _pause.height)
    love.graphics.setColor(255,255,255, 255)
    
    for i=1, #_pause.showMenu do
      love.graphics.print(_pause.showMenu[i],325,200+i* _pause.posY)
    end
    
    if _pause.menuSelect > 0 and _pause.menuSelect < #_pause.showMenu + 1  then -- pour compenser le temps de latence
      love.graphics.print("O",300,200 + _pause.menuSelect * _pause.posY)
    end
    
    if _pause.menuSelect > #_pause.showMenu then
      _pause.menuSelect = 1
    end
    if _pause.menuSelect < 1 then
      _pause.menuSelect = #_pause.showMenu
    end
    --debug
    --love.graphics.print(_pause.showMenu[_pause.menuSelect],10,10)
  end
end

function _pause:controller(key)
	if key == "down" then
		_pause.menuSelect = _pause.menuSelect + 1
	end
	if key == "up" then
		_pause.menuSelect = _pause.menuSelect - 1
	end
  
  
	if key == "space" then
    
    _pause.enable = false

    if _pause.showMenu[_pause.menuSelect] == "Restart" then
      loadLevel()
    elseif _pause.showMenu[_pause.menuSelect] == "Main Menu" then
			currentScene = "LEVELSELECT"
		elseif _pause.showMenu[_pause.menuSelect] == "Exit Game" then
			love.event.quit()
		end
    
    
	end
	
end


return _pause