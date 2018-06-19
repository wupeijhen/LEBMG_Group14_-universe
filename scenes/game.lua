-- Game Scene
-- All actual gameplay happens here.
-- This scene loads and shows many various little pieces from the rest of the project and combines them together.

local composer = require('composer') -- Scene management
local physics = require('physics') -- Box2D physics
local widget = require('widget') -- Buttons
local controller = require('libs.controller') -- Gamepad support
local databox = require('libs.databox') -- Persistant storage, track level completion and settings
local eachframe = require('libs.eachframe') -- enterFrame manager
local relayout = require('libs.relayout') -- Repositions elements on screen on window resize
local sounds = require('libs.sounds') -- Music and sounds manager
local newEndLevelPopup = require('classes.end_level_popup').newEndLevelPopup -- Win/Lose dialog windows

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local sword
local fireTimer
local bulletGroup=display.newGroup()
local enemies = display.newGroup()

--爆炸群組
local explosionGroup = display.newGroup()
local checkMemoryTimer

local numEnemy = 0
local enemyArray = {}
physics.start()
physics.setGravity(0, 0) -- Default gravity is too boring

local scene = composer.newScene()
local newSidebar = require('classes.sidebar').newSidebar -- Settings and pause sidebar

function scene:create(event)
	local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

	local group = self.view
	--self.levelId = event.params

  local game1 = display.newImageRect('images/background/game01.png', 480, 320)
  local game2 = display.newImageRect('images/background/game01.png', 480, 320)
    game1.x = 240
    game1.y = 160
    game2.x = 240+480
    game2.y = 160
    game1.speed = 2
    game2.speed = 2
    game1:toBack()
    game2:toBack()
    --background:insert(display.newGroup(game1,game2))
    group:insert(game1)
    group:insert(game2)
    --relayout.add(background)


  function scrollScenery(self,event)
        self.x = self.x - self.speed
        if self.x == -240 then
                self.x = 240+480
        end
    end
    game1.enterFrame = scrollScenery  --設定觸發時應執行的函式
    Runtime:addEventListener("enterFrame", game1)
    game2.enterFrame = scrollScenery
    Runtime:addEventListener("enterFrame", game2)

  self.levelId = event.params
  self.endLevelPopup = newEndLevelPopup({g = group, levelId = self.levelId})
  self.sidebar = newSidebar({g = group, levelId = self.levelId, onHide = function()
  self:setIsPaused(false)
  controller.setVisualButtons()
  end})

	local pauseButton = widget.newButton({
		defaultFile = 'images/buttons/pause.png',
		overFile = 'images/buttons/pause.png',
		width = 26, height = 24,
		x = _CX+200, y = _CY+120,
		onRelease = function()
			sounds.play('tap')
			self.sidebar:show()
			self:setIsPaused(true)
		end
	})
	pauseButton.anchorX, pauseButton.anchorY = 0, 0
	group:insert(pauseButton)
	relayout.add(pauseButton)

	self.sidebar:toFront()
--主角血量
  local smallSword = display.newImageRect('images/ammo/normal.png', 23, 40)
  smallSword.x = 20 
  smallSword.y = 20
  local small2 = display.newImageRect('images/ammo/normal.png', 23, 40)
  small2.x = 20 + 40
  small2.y = 20
  group:insert(smallSword)
  group:insert(small2)


	   --plane的動畫格設定
    local swordOptions =
    { 
      width = 65, --每格動畫格的寬度
      height = 30,--每格動畫格的高度
      numFrames = 6, --總共幾格
      swordContentWidth = 390, --動畫格總寬度  
      swordContentHeight = 30  --動畫格總高度
    }

    local swordSheet = graphics.newImageSheet( 'images/object/sword.png', swordOptions ) --將Ship讀取進來
    --定義並顯示在螢幕上包含標籤,跑幾格,多久時間內完成
    sword = display.newSprite( swordSheet, { name="sword", start=1, count=4, time=1000 } ) 
    sword.x=centerX*0.2 --ship的Ｘ座標
    sword.y=centerY --ship的Ｙ座標
    sword:play ( ) --讓動畫播放
    group:insert(sword)
    relayout.add(sword) --加到場景中

     --創建敵人function
    function createEnemy()
    numEnemy = numEnemy +1 
    print(numEnemy)

    local function removeEnemy( obj )
    --print("removeEnemy")
    createEnemy()
    --enemies:remove(obj)
    obj:removeSelf()
    obj=nil
    --print("enemies numChildren".. enemies.numChildren)
    end

    local enemyOptions =
    { 
      width = 66,
      height = 40,
      numFrames = 3,
      sheetContentWidth = 198,  
      sheetContentHeight = 40  
     }

    local enemySheet = graphics.newImageSheet( 'images/object/enemy.png', enemyOptions )

      enemyArray[numEnemy]  = display.newSprite(enemySheet, { name="enemy", start=1, count=3, time=1000 } )
      enemyArray[numEnemy] :play()
      physics.addBody ( enemyArray[numEnemy] , { isSensor = true,bounce = 0})--加入物理鋼體
      enemyArray[numEnemy].name = "enemy" 
      -- startlocationX = math.random (0, display.contentWidth)
      startlocationX = centerX*1.7
      enemyArray[numEnemy] .x = startlocationX
      --startlocationY = math.random (-500, -100)
      startlocationY  = math.random (0, display.contentHeight)
      enemyArray[numEnemy] .y = startlocationY
    
      transition.to ( enemyArray[numEnemy] , { time = math.random (6000, 10000), x= -50, y=enemyArray[numEnemy] .y ,onComplete =removeEnemy} )
      enemies:insert(enemyArray[numEnemy] )
      group:insert(enemies)
      
 end
 
local i
for i =1, 10 do
createEnemy()
end

end

--在子彈超過範圍後自動刪除
local function removeBullet( obj )
  --print("removeBullet")
  transition.cancel( obj )
  --bulletGroup:remove(obj)
  obj:removeSelf()
  obj=nil
  --print("bulletGroup numChildren".. bulletGroup.numChildren)
end
--開火
local function fire(  )
  sounds.play('shoot')
  print( "fire" )
  --呼叫子彈於船的前方
  local bullet = display.newImage( 'images/object/laser.png',sword.x+30,sword.y)
  --讓子彈自動往螢幕右側移動
  transition.to(bullet,  {time = 1000, x = display.viewableContentWidth+bullet.contentWidth/2,onComplete =removeBullet})
  physics.addBody(bullet, "dynamic", {bounce = 0})--加入物理鋼體
  bullet.name = "bullet"
  bulletGroup:insert(bullet)
  print("bulletGroup numChildren".. bulletGroup.numChildren)
end
--設定點擊到船的時候才開火
local function swordTouch(event)
  if event.phase=="began" then

    print("swordTouch_began")
    --延遲開火時間避免變成雷射炮
    fireTimer=timer.performWithDelay( 100, fire,0)
    display.getCurrentStage():setFocus(event.target)
  elseif ( event.phase == "moved" ) then
    --讓飛船位置＝點擊位置
     if  event.x >= sword.contentWidth/2 and event.x <= display.viewableContentWidth - sword.contentWidth/2 then
            sword.x=event.x
     end
     if  event.y >= sword.contentHeight/2 and event.y <= display.viewableContentHeight - sword.contentHeight/2 then
            sword.y=event.y
     end
        --print( "touch location in content coordinates = "..event.x..","..event.y )
    elseif ( event.phase == "ended" ) then
        display.getCurrentStage():setFocus(nil)
        print("swordTouch_ended")
        --停止觸碰船隻時便停止開火
        timer.cancel ( fireTimer )
        fireTimer=nil
  end
end

--移除爆炸
local function removExplode( obj )
    return function()
    obj:removeSelf() 
    obj=nil
    --print("explosionGroup numChildren".. explosionGroup.numChildren)
end 
end

--加入爆炸
local function explode( x,y )
  local explosionOptions =
  { 
      width = 55,
      height = 55,
      numFrames = 15,
      sheetContentWidth = 825,  
      sheetContentHeight = 55  
  }
  local explosionSheet = graphics.newImageSheet( 'images/object/explosion1.png', explosionOptions )
  local explosion = display.newSprite( explosionSheet, { name="explosion", start=1, count=15, time=1000 ,loopCount = 1 } )
  explosion.blendMode = "add"
  explosion.x=x
  explosion.y=y
  explosion:play()
  explosionGroup:insert(explosion)
  --print("explosionGroup numChildren".. explosionGroup.numChildren)
  sounds.play( 'explosion' )
math.random (-500, -100)
end

--加入物理碰撞偵測
local function onCollision( event )
    if ( event.phase == "began" ) then
      if  event.object1.name == "enemy" and event.object2.name == "bullet"  then
        --子彈碰到敵人,敵人消失
        print( "began: " .. event.object1.name .. " and " .. event.object2.name )
        removeBullet(event.object1)
        --消失同時呼叫爆炸，爆炸位置=敵人消失位置
        local x,y =event.object1.x,event.object1.y
        explode(x,y)
      end
    end
end

local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end



function scene:show(event)
	if event.phase == 'did' then
		eachframe.add(self) -- Each frame self:eachFrame() is called

		-- Only check once in a while for level end
		self.endLevelCheckTimer = timer.performWithDelay(2000, function()
			self:endLevelCheck()
		end, 0)

		-- Show help image once
		if not databox.isHelpShown then
			timer.performWithDelay(2500, function()
				self:setIsPaused(true)
			end)
		end
		sword:addEventListener( "touch",  swordTouch );
    Runtime:addEventListener( "collision", onCollision )

		sounds.playStream('game_music')
	end
end

controller.onKey = function(keyName, keyType)
    if not self.isPaused then
      if keyType == 'action' then
        if keyName == 'buttonA' and system.getInfo('platformName') == 'tvOS' then
          switchMotionAndRotation()
        else
          self.cannon:engageForce()
        end
      elseif keyType == 'pause' then
        pauseButton._view._onRelease()
      end
    end
  end

function scene:setIsPaused(isPaused)
	self.isPaused = isPaused
	--self.cannon.isPaused = self.isPaused -- Pause adding trajectory points
	if self.isPaused then
		physics.pause()
	else
		physics.start()
	end
end

-- Check if the player won or lost
function scene:endLevelCheck()
	if not self.isPaused then
		if i == 0 then
			sounds.play('win')
			self:setIsPaused(true)
			self.endLevelPopup:show({isWin = true})
			timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
      databox['level' .. self.levelId] = true
		elseif small2 == 0 then
			sounds.play('lose')
			self:setIsPaused(true)
			self.endLevelPopup:show({isWin = false})
			timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
		end
	end
end



-- Device's back button action
function scene:gotoPreviousScene()
	--native.showAlert('Corona Cannon', 'Are you sure you want to exit this level?', {'Yes', 'Cancel'}, function(event)
		if event.action == 'clicked' and event.index == 1 then
			composer.gotoScene('scenes.menu', {time = 500, effect = 'slideRight'})
		end
	--end)
end

-- Clean up
function scene:hide(event)
	if event.phase == 'will' then
		eachframe.remove(self)
		controller.onMotion = nil
		controller.onRotation = nil
		controller.onKey = nil
		if self.endLevelCheckTimer then
			timer.cancel(self.endLevelCheckTimer)
			Runtime:removeEventListener( "enterFrame", move );
		end
	elseif event.phase == 'did' then
		physics.stop()
	end
end

scene:addEventListener('create')
scene:addEventListener('show')
scene:addEventListener('hide')

return scene
