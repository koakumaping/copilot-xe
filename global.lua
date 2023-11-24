-- global value
gModelFlyCounts = 0
gIsFullScreen = 0

-- timer
gTimerStart = 0
gTimerDirection = 1

local module = {}

function module.wakeup(widget)
  -- print(system.getMemoryUsage().mainStackAvailable)
  -- table.insert(testTabele, {
  --   speed=200,
  --   rssi=50,
  --   RxBatt=22.5,
  --   thr=1024,
  -- })

  local _timerStart = model.getTimer(0):start()
  if gTimerStart ~= _timerStart then
    gTimerStart = _timerStart
  end

  local _gTimerDirection = model.getTimer(0):direction()
  if gTimerDirection ~= _gTimerDirection then
    gTimerDirection = _gTimerDirection
  end
end

return module