local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 230
local moduleHeight = 60

local _modelFlyCounts = 0

local startDate = ''
local stopDate = ''

local countsRecordFile = '/csv/fly.csv'

local recordFileTitle = 'No,FlyTime,LandingVoltage,RSSI24G(min),RSSI900M(min),StartDate,StopDate\n'
local recordFileName = ''
-- 延迟记录时间
local realRecordTime = 0

local lastFlyTime = 0

local staticTime <const> = 999999999
local minFlyTime <const> = 3

local timerStart = model.getTimer(0):start()

function getTime()
  return os.date("%Y-%m-%d %H:%M:%S", os.time())
end

function module.saveConuts()
  local data = 'Name,FlyTimes,LastFlyDate\n'
  local csv = io.open(countsRecordFile, 'r')

  local count = 1
  local saved = 0
  while csv do
    local line = csv:read('*line')
    if line == nil then
      csv:close()
      break
    end
    if count ~= 1 then
      local _name, _flyTimes, _lastFlyTime = line:match('([^,]+),([^,]+),([^,]+)')
      if _name == model.name() then
        _flyTimes = _modelFlyCounts
        _lastFlyTime = getTime()
        saved = 1
      end
      data = string.format('%s%s,%d,%s\n', data, _name, _flyTimes, _lastFlyTime)
    end
    count = count + 1
  end

  -- if no data in csv
  if saved == 0 then
    data = string.format('%s%s,%d,%s\n', data, model.name(), _modelFlyCounts, getTime())
  end

  csv:close()
  -- save to file
  local filewrite = io.open(countsRecordFile, 'w')
  filewrite:write(data)
  filewrite:close()
end

function module.saveRecord()
  realRecordTime = staticTime
  local data = recordFileTitle
  local csv = io.open(recordFileName, 'r')

  local count = 1
  while csv do
    local line = csv:read('*line')
    if line == nil then
      csv:close()
      break
    end
    if count ~= 1 then
      data = string.format('%s%s\n', data, line)
    end
    count = count + 1
  end
  csv:close()

  local ext = 0
  local source = system.getSource({ name='ADC2' })
  if source ~= nil then
    ext = source:value()
  end

  local lastFlyTimeSeconds = string.format('%02d', lastFlyTime % 60)
  local lastFlyTimeMinutes = string.format('%02d', (lastFlyTime - lastFlyTimeSeconds) / 60)

  data = string.format('%s%s,%s,%s,%s,%s,%s,%s\n',
    data,
    string.format('%04d', _modelFlyCounts),
    string.format('%s:%s', lastFlyTimeMinutes, lastFlyTimeSeconds),
    string.format('%05.2f%s(%03.2f%s)', ext, 'v', ext / 6, 'v'),
    string.format('%02.0f', util.getRSSI24GMinValue()),
    string.format('%02.0f', util.getRSSI900MMinValue()),
    startDate,
    stopDate
  )

  -- print(data)
  -- save to file
  local file2save = io.open(recordFileName, 'w')
  file2save:write(data)
  file2save:close()
  model.getTimer(0):value(model.getTimer(0):start())
  system.playFile('Saved.wav')
end

function module.init()
  recordFileName = string.format('%s%s%s', '/csv/', model.name(), '.csv')
  local csv = io.open(countsRecordFile, 'r')
  -- creat if not exist
  if csv == nil then
    filewrite = io.open(countsRecordFile, 'w')
    filewrite:write('Name,FlyTimes,LastFlyTime\n')
    filewrite:close()
    csv = io.open(countsRecordFile, 'r')
  end

  while csv do
    local line = csv:read('*line')
    if line == nil then
      csv:close()
      break
    end
    local name, flyTimes = line:match("([^,]+),([^,]+)")
    if name == model.name() then
      _modelFlyCounts = flyTimes
      csv:close()
      break
    end
  end

  -- creat if not exist
  local data = recordFileTitle
  local csv = io.open(recordFileName, 'r')
  if csv == nil then
    local filewrite = io.open(recordFileName, 'w')
    filewrite:write(data)
    filewrite:close()
  else
    csv:close()
  end
end

function module.add(widget)
  lastFlyTime = widget.lastFlyTime
  _modelFlyCounts = _modelFlyCounts + 1
  module:saveConuts()
  module:saveRecord()
end

function module.start()
  startDate = getTime()
end

function module.stop()
  stopDate = getTime()
end

function module.handleRecord(widget, value)
  local S3 = system.getSource('SC'):value()
  -- start
  if S3 > 0 then
    local _timerValue = model.getTimer(0):value()
    if timerStart == _timerValue then
      module.start()
    end
  end
  -- end
  if S3 < 0 then
    module.stop()
  end
end

function module.handleFlyEnd(widget)
  local _timerValue = model.getTimer(0):value()
  print(timerStart, _timerValue, timerStart - _timerValue)
  if timerStart - _timerValue > minFlyTime and os.time() > realRecordTime then
    module.add(widget)
  end
end

function module.wakeup(widget)
  if modelFlyCounts ~= _modelFlyCounts then
    modelFlyCounts = _modelFlyCounts
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  local _timerStart = model.getTimer(0):start()
  if timerStart ~= _timerStart then
    timerStart = _timerStart
  end

  module.handleRecord(widget)

  local S3 = system.getSource('SC'):value()
  -- S3 up
  if S3 < 0 then
    module.handleFlyEnd(widget)
  end

  -- S3 down
  if S3 > 0 then
    -- 延迟记录时间 6s
    realRecordTime = os.time() + 10
  end
end

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y - 4
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  lcd.color(var.textColor)
  util.drawChar(widget, xStart, yStart, string.format('%04d', modelFlyCounts))
end

return module