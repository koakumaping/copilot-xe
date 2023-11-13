local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 230
local moduleHeight = 60

local hasInit = 0
local current = 0
local _current = 0

local startDate = ''
local stopDate = ''

-- local modelName = model.name()
local countsRecordFile = '/csv/fly.csv'

local recordFileTitle = 'No,FlyTime,LandingVoltage,RSSI24G(min),RSSI900M(min),StartDate,StopDate\n'
local recordFileName = string.format('%s%s%s', '/csv/', modelName, '.csv')
-- 延迟记录时间
local recordTime = 0
-- 延迟记录标记
local recordFlag = 1

local lastFlyTime = 0

local staticTime <const> = 999999999
local rangeSeconds <const> = 60

local countStartTime = staticTime
local countStartTimeRecording = false
local countEndTime = staticTime
local countEndTimeRecording = false

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
      if _name == modelName then
        _flyTimes = _current
        _lastFlyTime = getTime()
        saved = 1
      end
      data = string.format('%s%s,%d,%s\n', data, _name, _flyTimes, _lastFlyTime)
    end
    count = count + 1
  end

  -- if no data in csv
  if saved == 0 then
    data = string.format('%s%s,%d,%s\n', data, modelName, _current, getTime())
  end

  csv:close()
  -- save to file
  local filewrite = io.open(countsRecordFile, 'w')
  filewrite:write(data)
  filewrite:close()
end

function module.saveRecord()
  recordTime = 0
  recordFlag = 1
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
    string.format('%04d', _current),
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
  needRefrshRecords = 1
end

function module.inits()
  recordFileName = string.format('%s%s%s', '/csv/', modelName, '.csv')
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
    if name == modelName then
      _current = flyTimes
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

  hasInit = 1
end

function module.add(widget)
  lastFlyTime = widget.lastFlyTime
  _current = _current + 1
  module:saveConuts()
  recordFlag = 0
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
  if S3 > 0 and not countStartTimeRecording then
    local timerStart = model.getTimer(0):start()
    local timerValue = model.getTimer(0):value()
    countEndTimeRecording = false
    if timerStart == timerValue then
      countStartTime = os.clock()
      countStartTimeRecording = true
      countEndTime = staticTime
      module.start()
    end
  end
  -- end
  if S3 < 0 and not countEndTimeRecording then
    countEndTime = os.clock()
    countStartTimeRecording = false
    countEndTimeRecording = true

    module.stop()
  end
end

local time = 0
function module.handleReset(widget)
  if countEndTimeRecording and countEndTime ~= staticTime then
    if countEndTime - countStartTime > rangeSeconds then
      countStartTime = staticTime
      countEndTime = staticTime
      module.add(widget)
    end
  end

  if os.time() > recordTime and recordFlag == 0 then
    module:saveRecord()
  end
end

function module.wakeup(widget)
  -- local needLcdInvalidate = false
  -- local _time = math.floor(os.clock())
  -- if time ~= _time then
  --   time = _time
  --   local integer, decimal = math.modf(time / 1)
  --   if decimal == 0 then
  --     print('recordTime', recordTime)
  --     print('recordFlag', recordFlag)
  --     print('countStartTime', countStartTime)
  --     print('countStartTimeRecording', countStartTimeRecording)
  --     print('countEndTime', countEndTime)
  --     print('-------------------------------------------------')
  --   end
  --   needLcdInvalidate = true
  -- end
  if hasInit == 0 then
    module.inits()
  end
  -- print('current', current, _current)
  if current ~= _current then
    print('current change', current)
    current = _current
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  module.handleRecord(widget)

  local S3 = system.getSource('SC'):value()
  -- S3 up
  if S3 < 0 then
    module.handleReset(widget)
  end

  -- S3 down
  if S3 > 0 then
    -- 延迟记录时间 6s
    recordTime = os.time() + 6
    if recordFlag ~= 0 then recordFlag = 0 end
  end
end

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y - 4
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  lcd.color(var.textColor)
  util.drawChar(widget, xStart, yStart, string.format('%04d', current))
end

return module