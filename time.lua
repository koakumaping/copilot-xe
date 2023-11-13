local module = {}

local mask = lcd.loadMask('./bitmaps/time.png')

local moduleX = 0
local moduleY = 0
local moduleWidth = 48 * 4 + 22
local moduleHeight = 90

local flyTime = 0
local allTime = 0
local isMinus = false

local played = false
local playTime = os.clock()

function module.wakeup(widget)
  local _direction = model.getTimer(0):direction()
  local _flyTime = tonumber(model.getTimer(0):value())
  local _allTime = tonumber(model.getTimer(1):value())

  if _flyTime < 0 then
    isMinus = true
  else
    isMinus = false
  end

  if _flyTime ~= flyTime then
    flyTime = isMinus and (0 - _flyTime) or  _flyTime
    widget.lastFlyTime = _direction < 0 and model.getTimer(0):start() - _flyTime or _flyTime
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)

    -- reset paly flag
    if playTime + 2 < os.clock() and played == true then
      played = false
    end
    -- play countdown vioce
    if played == true then return end

    local minutes = 60
    if _direction < 0 then
      for i = 10, 1, -1 do
        if _flyTime == i * minutes + 1 then
          system.playFile(string.format('%d%s', i, 'm.wav'))
          played = true
          playTime = os.clock()
        end
      end
      if _flyTime == 91 then
        system.playFile('1m30s.wav')
        played = true
        playTime = os.clock()
      end
      if _flyTime == 31 then
        system.playFile('30s.wav')
        played = true
        playTime = os.clock()
      end
      if _flyTime == 1 then
        system.playFile('TimeEnd.wav')
        played = true
        playTime = os.clock()
      end
    end
  end

  if _allTime ~= allTime then
    allTime = _allTime
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 33
  local yStart = y

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  local flyTimeSeconds = string.format('%02d', flyTime % 60)
  local flyTimeMinutes =
    isMinus and string.format('%s%01d', '-', (flyTime - flyTimeSeconds) / 60)
    or string.format('%02d', (flyTime - flyTimeSeconds) / 60)

  local lastFlyTimeSeconds = string.format('%02d', widget.lastFlyTime % 60)
  local lastFlyTimeMinutes = string.format('%02d', (widget.lastFlyTime - lastFlyTimeSeconds) / 60) 

  local allTimeHour = string.format('%02d', math.floor(allTime / 3600))
  local allTimeMinutes = string.format('%02d', math.floor((allTime - allTimeHour * 3600) / 60))

  -- if switchTable[5] > 0 then
  --   if flyTimeSeconds % 2 == 0 then
  --     lcd.color(blackColor)
  --   else
  --     lcd.color(themeBgColor)
  --   end
  -- else
  --   lcd.color(blackColor)
  -- end

  util.drawChar(widget, xStart, yStart, string.format('%s:%s', flyTimeMinutes, flyTimeSeconds))
  lcd.color(var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 86, yStart + 62, string.format('%s:%s .. %s:%s', lastFlyTimeMinutes, lastFlyTimeSeconds, allTimeHour, allTimeMinutes))

  -- lcd.color(var.themeColor)
  -- lcd.drawFilledRectangle(xStart + 2 + 4, yStart + 69 + 2, 200, 16)
  -- lcd.color(var.textColor)
  -- lcd.drawMask(xStart + 4, yStart + 69, mask)
end

return module