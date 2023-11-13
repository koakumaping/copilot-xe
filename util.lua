local var = dofile('/scripts/copilot-xe/var.lua')

local module = {}

local MAX = 1024

local number0 = lcd.loadMask('./bitmaps/0.png')
local number1 = lcd.loadMask('./bitmaps/1.png')
local number2 = lcd.loadMask('./bitmaps/2.png')
local number3 = lcd.loadMask('./bitmaps/3.png')
local number4 = lcd.loadMask('./bitmaps/4.png')
local number5 = lcd.loadMask('./bitmaps/5.png')
local number6 = lcd.loadMask('./bitmaps/6.png')
local number7 = lcd.loadMask('./bitmaps/7.png')
local number8 = lcd.loadMask('./bitmaps/8.png')
local number9 = lcd.loadMask('./bitmaps/9.png')
local colon = lcd.loadMask('./bitmaps/colon.png')
local dot = lcd.loadMask('./bitmaps/dot.png')
local minus = lcd.loadMask('./bitmaps/minus.png')
local charV = lcd.loadMask('./bitmaps/V.png')
local charS = lcd.loadMask('./bitmaps/S.png')

local topLeftMask = lcd.loadMask('./bitmaps/tl.png')
local topRightMask = lcd.loadMask('./bitmaps/tr.png')
local bottomLeftMask = lcd.loadMask('./bitmaps/bl.png')
local bottomRightMask = lcd.loadMask('./bitmaps/br.png')

function module.getCharMask(value)
  if value == 0 or value == '0' then return number0 end
  if value == 1 or value == '1' then return number1 end
  if value == 2 or value == '2' then return number2 end
  if value == 3 or value == '3' then return number3 end
  if value == 4 or value == '4' then return number4 end
  if value == 5 or value == '5' then return number5 end
  if value == 6 or value == '6' then return number6 end
  if value == 7 or value == '7' then return number7 end
  if value == 8 or value == '8' then return number8 end
  if value == 9 or value == '9' then return number9 end

  if value == '.' then return dot end
  if value == '-' then return minus end

  if value == 'S' then return charS end
  if value == 'V' then return charV end
  return colon
end

function module.drawChar(widget, x, y, value)
  lcd.color(var.textColor)
  local s = tostring(value)
  local xStart = x

  for i = 1, string.len(s) do
    local current = string.sub(s, i, i)
    lcd.drawMask(xStart, y, module.getCharMask(current))
    if current == '.' or current == ':' then
      xStart = xStart + var.dotWidth
    else
      xStart = xStart + var.fontWidth
    end
  end
end

function module.drawBox(widget, x, y, w, h, f)
  lcd.color(lcd.RGB(225, 225, 225))
  lcd.drawFilledRectangle(x, y, w, h)

  lcd.color(var.bgColor)
  lcd.drawMask(x, y, topLeftMask)
  lcd.drawMask(x + w - 6, y, topRightMask)
  lcd.drawMask(x, y + h - 6, bottomLeftMask)
  lcd.drawMask(x + w - 6, y + h - 6, bottomRightMask)

  if f then f(widget, x + 8, y + 12) end
end

function module.convertTrim(value)
  local fixedValue = value + MAX
  local step = 48

  -- fix center if trim value is very small

  if value > 0 and value < step then fixedValue = MAX + step end
  if value < 0 and value > -step then fixedValue = MAX - step end

  return fixedValue // step
end

function module.convertReverseTrim(value)
  local fixedValue = value + MAX
  local step = 48

  -- fix center if trim value is very small

  if value > 0 and value < step then fixedValue = MAX + step end
  if value < 0 and value > -step then fixedValue = MAX - step end

  return 2000 / step - fixedValue // step
end

function module.convertChannel(value)
  local fixedValue = -value
  local step = 36

  return fixedValue // step
end

function module.convertThrChannel(value)
  local fixedValue = value + MAX
  local step = 36

  return fixedValue // step
end

function module.getTime()
  return os.date("%Y-%m-%d %H:%M:%S", os.time())
end

function module.getRSSI24GMinValue()
  local sourceRSSI24GMin = system.getSource({ name='RSSI', options=OPTION_SENSOR_MIN }) == nil and
  system.getSource({ name='RSSI 2.4G', options=OPTION_SENSOR_MIN }) or system.getSource({ name='RSSI', options=OPTION_SENSOR_MIN })
  return sourceRSSI24GMin == nil and -1 or sourceRSSI24GMin:value()
end

function module.getRSSI900MMinValue()
  local sourceRSSI900MMin = system.getSource({ name='RSSI 900M', options=OPTION_SENSOR_MIN })
  return sourceRSSI900MMin == nil and -1 or sourceRSSI900MMin:value()
end

return module