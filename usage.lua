local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 230
local moduleHeight = 180

local fileName = '/csv/usage.txt'
local timeInFile = 0
local time = 0

function module.init()
  local csv = io.open(fileName, 'r')
  -- creat if not exist
  if csv == nil then
    filewrite = io.open(fileName, 'w')
    filewrite:write(0)
    filewrite:close()
    csv = io.open(fileName, 'r')
  end

  local line = csv:read('*line')
  if line ~= nil then
    timeInFile = tonumber(line)
    csv:close()
  end
end

function module.save()
  filewrite = io.open(fileName, 'w')
  filewrite:write(time + timeInFile)
  filewrite:close()
end

function module.wakeup(widget)
  local needLcdInvalidate = false
  local _time = math.floor(os.clock())
  if time ~= _time then
    time = _time
    local integer, decimal = math.modf(time / 10)
    if decimal == 0 then module.save() end
    needLcdInvalidate = true
  end

  if needLcdInvalidate then
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y - 4
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  local integer, decimal = math.modf((time + timeInFile) / 3600)
  util.drawChar(widget, xStart, yStart, string.format('%04d', integer))
end

return module