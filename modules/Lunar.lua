_Lunar = {}

lunar_mode = false
lunar_ship = {}

function _Lunar:load( )
    lunar_ship.vec = {x = 0, y = 0}
    lunar_ship.image = love.graphics.newImage("images/ship.png")
    lunar_ship.pos = {x = width/2-lunar_ship.image:getWidth()/2, y = height/2-lunar_ship.image:getHeight()/2}
    lunar_ship.r = -90
    lunar_ship.fire_on = false
    lunar_ship.fire = love.graphics.newImage("images/engine.png")
  
    love.keyboard.setKeyRepeat(false)
end

function _Lunar:update(dt)
    if (lunar_mode) then
        lunar_ship.fire_on = false
        if (love.keyboard.isDown("space")) then
          lunar_ship.fire_on = true
        end
        if (love.keyboard.isDown("left")) then
          lunar_ship.r = lunar_ship.r-5
        elseif (love.keyboard.isDown("right")) then
          lunar_ship.r = lunar_ship.r+5
        end
        
        if (lunar_ship.pos.x<0)then 
          lunar_ship.pos.x = width 
          lunar_ship.pos.y = height-lunar_ship.pos.y
        end
        if (lunar_ship.pos.x>width)then 
          lunar_ship.pos.x = 0
          lunar_ship.pos.y = height-lunar_ship.pos.y
        end
        
        if (lunar_ship.pos.y>height) then
          lunar_ship.vec.x = 0
          lunar_ship.vec.y = 0
          lunar_ship.pos = {x = width/2-lunar_ship.image:getWidth()/2, y = height/2-lunar_ship.image:getHeight()/2}
          lunar_ship.r = -90
        end
        
        if (lunar_ship.pos.y<0) then
          Level.goToNextLevel()
          loadLevel()
          lunar_ship.vec.x = 0
          lunar_ship.vec.y = 0
          lunar_ship.pos = {x = width/2-lunar_ship.image:getWidth()/2, y = height/2-lunar_ship.image:getHeight()/2}
          lunar_mode = false
          lunar_ship.r = -90
          lunar_ship.fire_on = false
          love.keyboard.setKeyRepeat(false)
          return false
        end
        lunar_ship.pos.x = lunar_ship.pos.x+lunar_ship.vec.x*dt
        lunar_ship.pos.y = lunar_ship.pos.y+lunar_ship.vec.y*dt
        lunar_ship.vec.x = lunar_ship.vec.x+math.cos(math.rad(lunar_ship.r))*250 *dt
        if (lunar_ship.fire_on)then 
          print("oui")
          lunar_ship.vec.y = lunar_ship.vec.y-math.sin(math.rad(lunar_ship.r+180))*500*dt
        end
        lunar_ship.vec.y = lunar_ship.vec.y+200*dt
        love.keyboard.setKeyRepeat(true)
      end
end


return _Lunar