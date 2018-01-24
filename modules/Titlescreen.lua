titleScreen = {
	img = love.graphics.newImage("images/titlescreen/gootorigin.png"),
	pStart = "Press space to start"
	}

timer=0
tRst = 50
function titleScreen:draw()
	timer = timer + 1
	
	love.graphics.draw(titleScreen.img,0,0,0,4,4)
	
	if timer < tRst then
		love.graphics.print(titleScreen.pStart, 250,500)
	elseif timer > tRst * 2 then
		timer = 0
	end
	
end

function titleScreen:controller(key)
	if key == "space" then
			currentScene = "MAINMENU"
		end
end



return titleScreen