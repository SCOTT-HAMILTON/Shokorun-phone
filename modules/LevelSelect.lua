_levelSelect = {}

local bg_image = love.graphics.newImage( "images/ui/lvlselect/bg_card.png" )
local cardImg = love.graphics.newImage( "images/ui/lvlselect/card.png" )
local starImg = love.graphics.newImage( "images/ui/lvlselect/starsEndLevel.png" )

local moveX = 0
local moveY = 0
local rOn = false
local lOn = false
local speedMoveMenu = 20
local tempsLevel = 50
local rectsCards = {}

local _bg = {
    width = 500,
    height = 350,
    x = 0,
    y = 0
}

local _level = {
    width       = 60,
    height      = 80,
    x           = 0,
    y           = 0,
    color       = {55,0,256,255},
    borderColor = {55,0,20,255} 
}

local selector = {
    posX = 1, -- incrémentation des positions numérique sur x
    posY = 1, -- "" y
    x = 0, -- position x
    y = 0, -- position y
    val = 1, -- valeur du selecteur sur la position du selecteur de niveau
    bgPos = 1
}




local dir = "/level"
_levelSelect.lvlFiles = love.filesystem.getDirectoryItems(dir)
local iLevel = math.floor(#_levelSelect.lvlFiles / 15) + 1

function  _levelSelect:load()
    _bg.x = love.graphics.getWidth()/2 - _bg.width/2
    _bg.y = love.graphics.getHeight()/2 - _bg.height/2
end

function _levelSelect:draw()
    rectsCards = {}
    --deplacement du menu
    changeZone()

    -- creation du background color
    creatCardBg()
    
    -- level square
    posXn = 1
    posYn = 1
    
    -- draw card
    for i = 1, #_levelSelect.lvlFiles do 
        
            local posX = (100 * posXn) - 80
            local posY = (100 * posYn) - 80 
            posXn = posXn + 1
            if i % 5  == 0  then
                posYn = posYn + 1
                posXn = 1 
            end
            

            if i <  (#_levelSelect.lvlFiles + 1 - (selector.bgPos * 15 - 15))  then
                if i < 16 then
            --card level item
                love.graphics.setColor(255,255,255,255)
                local tmp_val = selector.val
                if (tmp_val>=16) then
                  tmp_val = tmp_val%16+1
                end
                if (tmp_val == i) then
                  love.graphics.setColor(0,255, 255, 255)
                  love.graphics.rectangle("fill", _bg.x + posX-2,  _bg.y + posY-2,  _level.width + 5,_level.height+5, 10,10,30)
                  love.graphics.setColor(255,255, 255, 255)
                end
                love.graphics.draw(cardImg, _bg.x + posX,  _bg.y + posY,0, 1, 1)
                rectsCards[#rectsCards+1] = {x = _bg.x + posX, y = _bg.y + posY}
                
                --love.graphics.rectangle("fill", _bg.x + posX, _bg.y + posY, _level.width,_level.height, 10,10,30)
                love.graphics.setColor(255,0,0,255)
                love.graphics.print(i + selector.bgPos * 15 - 15, _bg.x + posX,  _bg.y + posY,0,1.5,1.5,-15,5)
                love.graphics.setColor(0,0,0,0) -- reset bg color
                end
            end
    end

    --selector pos
    for i=1 , iLevel do
        if selector.bgPos == i then
        love.graphics.setColor(255,0,0,255)
        else
        love.graphics.setColor(255,255,255,255)            
        end
        love.graphics.circle("fill",love.graphics.getWidth()/2 + i * 25 - 25,_bg.y + 390,10, 50)
    end

    --debug
    love.graphics.setColor(255,255, 255, 255)
    love.graphics.print("selector.posx : "..selector.posX,10,10,0,0.5,0.5)
    love.graphics.print("selector.posy: ".. selector.posY,10,20,0,0.5,0.5)
    love.graphics.print("selector.val : ".. selector.val,10,30,0,0.5,0.5)
    love.graphics.print("selector.val + 5 : ".. selector.val + 5 ,10,40,0,0.5,0.5)
    love.graphics.print("#_levelSelect.lvlFiles : ".. #_levelSelect.lvlFiles ,10,50,0,0.5,0.5)
end

function _levelSelect:controller(pos, key)
  if (key ~= nil) then
    
    if key == "right" and selector.val < #_levelSelect.lvlFiles  then
      if lOn == false and selector.bgPos < iLevel then
        rOn = true
        selector.bgPos = selector.bgPos + 1
      end
    end
    if key == "left"  then
      if rOn == false and selector.bgPos > 1 then
        lOn = true
        selector.bgPos = selector.bgPos - 1
      end
    end
    if key == "up" and selector.posY > 1 then
        selector.posY = selector.posY - 1
    end
    if key == "down" and selector.posY < 3  and selector.val + 5 <= #_levelSelect.lvlFiles  then
        selector.posY = selector.posY + 1
    end
    return false
  end
  
  if (touch_screen or love.mouse.isDown(1)) then
    for i = 1, #rectsCards do
      if (p2rectCollide(rectsCards[i], pos)) then
        local val = i
        val = val+ (selector.bgPos-1)*5*3
        print("val : "..val)
        selector.val = val
      end
    end
  end
end

function chooseLevel()
    
end

function p2rectCollide(rect, pos)
  print("rect : "..type(rect))
  print("pos : "..type(pos))
  if (
    pos.x>rect.x+cardImg:getWidth() or
    pos.x < rect.x or
    pos.y>rect.y+cardImg:getHeight()+4 or
    pos.y < rect.y
  ) then
    return false
  end
  return true
end

function _levelSelect:getVal()
  return selector.val
end

function creatCardBg()
    love.graphics.setColor(255,255,255,255)
    for i=1, iLevel do
        love.graphics.draw(bg_image, _bg.x  + moveX + (i*800) - 800, _bg.y  )
        --love.graphics.rectangle("fill", _bg.x  + moveX + (i*800) - 800, _bg.y , _bg.width , _bg.height ,0,0,0)
    end
end


function changeZone()
    if rOn  then
        moveX = moveX - 1 * speedMoveMenu
    end
    if lOn  then
        moveX = moveX + 1 * speedMoveMenu
    end
    if moveX%800 == 0  then
        rOn =false
        lOn =false
    end
    
end

return _levelSelect