_mainMenu = {
	showMenu= {},
	menuSelect = 1,
	posY = 30
}

menu = {
	{"Start", "Option"},
	Option = {"SFX", "Music", "Reset", "Back"}
	}



function _mainMenu:load()
	_mainMenu.showMenu = menu[1]
end


function _mainMenu:draw()
	
	for i=1, #_mainMenu.showMenu do
		love.graphics.print(_mainMenu.showMenu[i],200,200+i* _mainMenu.posY)
	end
	
	if _mainMenu.menuSelect > 0 and _mainMenu.menuSelect < #_mainMenu.showMenu + 1  then -- pour compenser le temps de latence
		love.graphics.print("O",180,200 + _mainMenu.menuSelect * _mainMenu.posY)
	end
	
	if _mainMenu.menuSelect > #_mainMenu.showMenu then
		_mainMenu.menuSelect = 1
	end
	if _mainMenu.menuSelect < 1 then
		_mainMenu.menuSelect = #_mainMenu.showMenu
	end
	--debug
	love.graphics.print(_mainMenu.showMenu[_mainMenu.menuSelect],10,10)
end

function _mainMenu:controller(key)
	if key == "down" then
		_mainMenu.menuSelect = _mainMenu.menuSelect + 1
	end
	if key == "up" then
		_mainMenu.menuSelect = _mainMenu.menuSelect - 1
	end
	
	if key == "space" then
		if _mainMenu.showMenu[_mainMenu.menuSelect] == "Start" then
			currentScene = "LEVELSELECT"
		elseif _mainMenu.showMenu[_mainMenu.menuSelect] == "Option" then
			_mainMenu.showMenu = menu[_mainMenu.showMenu[_mainMenu.menuSelect]]
		elseif _mainMenu.showMenu[_mainMenu.menuSelect] == "Back" then
			_mainMenu.showMenu = menu[1]
			
		end
		
		
	end
	
end


return _mainMenu