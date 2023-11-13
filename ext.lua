local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 180
local moduleHeight = 180

local ext = 0
local extMin = 0
local extMax = 0
local extCell = 0
local extCellMin = 0
local extCellMax = 0

function module.wakeup(widget)
  local source = system.getSource({ name='ADC2' })
  local sourceMin = system.getSource({ name='ADC2', options=OPTION_SENSOR_MIN })
  local sourceMax = system.getSource({ name='ADC2', options=OPTION_SENSOR_MAX })
  if source == nil then
    local _ext = 0
    if _ext ~= ext then
      ext = _ext
      extCell = 0
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  else
    local _ext = source:value()
    local _extMin = sourceMin:value()
    local _extMax = sourceMax:value()
    if _ext ~= ext then
      ext = _ext
      extCell = _ext / 6
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
    if _extMin ~= extMin then
      extMin = _extMin
      extCellMin = _extMin / 6
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
    if _extMax ~= extMax then
      extMax = _extMax
      extCellMax = _extMax / 6
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  end
end

function module.paint(widget, x, y)
  local xStart = x
  local yStart = y
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  util.drawChar(widget, xStart + 15, yStart, string.format('%04.1f%s', ext, 'V'))

  lcd.color(var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(xStart + 40 + 15, yStart + 62, string.format('%04.2f%s%04.2f%s', extCellMin == MAX and 0 or extCellMin, ' .. ' , extCellMax, ' v'))
end

function module.paintCell(widget, xStart, yStart)
  util.drawChar(widget, xStart + 15, yStart - 4, string.format('%04.2f%s', extCell, 'V'))
end

return module