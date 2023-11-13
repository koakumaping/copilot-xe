local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 230
local moduleHeight = 180

local gps = 0
local speed = 0
local speedMax = 0

function module.wakeup(widget)
  local source = system.getSource({ name='GPS Speed' })
  local sourceMax = system.getSource({ name='GPS Speed', options=OPTION_SENSOR_MAX })
  if source == nil then
    if gps == 1 then gps = 0 end
    local _speed = 0
    local _speedMax = 0
    if _speed ~= speed then
      speed = _speed
    end
    if _speedMax ~= speedMax then
      speedMax = _speedMax
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  else
    local _speed = source:value()
    local _speedMax = sourceMax:value()
    if gps == 0 then gps = 1 end
    if _speed ~= speed then
      speed = _speed
    end
    if _speedMax ~= speedMax then
      speedMax = _speedMax
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  end
end

function module.paint(widget, x, y)
  local xStart = x - 12
  local yStart = y - 4
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  local front, second = math.modf(speedMax)

  util.drawChar(widget, xStart + 15, yStart, string.format('%05.1f', speedMax))

  -- lcd.color(textColor)
  -- lcd.font(FONT_XL)
  -- lcd.drawText(xStart + 176, yStart + 26, math.floor(second * 100))
end

function module.paintStatus(widget, xStart, yStart)
  util.drawChar(widget, xStart + 15, yStart - 4, gps)
end

return module