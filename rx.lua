local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 180
local moduleHeight = 88

local rxBatt = 0
local rxBattMin = 0
local rxBattMax = 0

function module.wakeup(widget)
  local source = system.getSource({ name='RxBatt' })
  local sourceMin = system.getSource({ name='RxBatt', options=OPTION_SENSOR_MIN })
  local sourceMax = system.getSource({ name='RxBatt', options=OPTION_SENSOR_MAX })
  if source == nil then
    local _rxBatt = 0
    if _rxBatt ~= rxBatt then
      rxBatt = _rxBatt
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  else
    local _rxBatt = source:value()
    local _rxBattMin = sourceMin:value()
    local _rxBattMax = sourceMax:value()
    if _rxBatt ~= rxBatt then
      rxBatt = _rxBatt
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
    if _rxBattMin ~= rxBattMin then
      rxBattMin = _rxBattMin
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
    if _rxBattMax ~= rxBattMax then
      rxBattMax = _rxBattMax
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  end
end

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  util.drawChar(widget, xStart, yStart, string.format('%04.2f%s', rxBatt, 'V'))

  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(xStart + 40, yStart + 62, string.format('%04.2f%s%04.2f%s', rxBattMin == var.MAX and 0 or rxBattMin, ' .. ' , rxBattMax, ' v'))
end

return module