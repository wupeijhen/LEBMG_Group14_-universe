
local sword = {}
local sword_mt = { __index = sword }


function sword.new( posx, posy)
  local newship = {}
  smallSword.image = display.newImageRect('images/ammo/normal.png',23,40)
  physics.addBody(smallSword.image, "static", {friction=0, bounce = 0})
  smallSword.image.x = 10
  smallSword.image.Y = display.contentWidth-30
  smallSword.e= true
  smallSword.type="Ship"
  return setmetatable( smallSword, sword_mt )
end

function sword:tap(event)
  -- The ship is moved by a event from main
  print("sword moved")
  self.image.x= event.x
end

-------------------------------------------------


return sword