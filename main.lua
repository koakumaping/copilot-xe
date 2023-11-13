local function loadLib(name)
  local lib = dofile('/scripts/copilot-xe/'..name..'.lua')
  if lib.init ~= nil then
    lib.init()
  end
  return lib
end
-- global var
modelName = ''
var = loadLib('var')
util = loadLib('util')
counts = loadLib('counts')

needRefrshRecords = 1
isFullScreen = 0

local time = loadLib('time')
local bitmap = loadLib('bitmap')
local ext = loadLib('ext')
local rx = loadLib('rx')
local copyright = loadLib('copyright')
local gps = loadLib('gps')
local usage = loadLib('usage')

local function create()
  return {
    w = 784,
    h = 316,
    bitmap = lcd.loadBitmap(model.bitmap()),
    flyCounts = 0,
    -- message = '',
    messageStartTime = 0,
    messageEndTime = 0,
    lastFlyTime = 0,
  }
end

local function menu(widget)
  return {
    {'Lua Menu Test',
      function()
        local sensor = system.getSource({ name='RxBatt' })
        system.playNumber(sensor:value(), sensor:unit(), sensor:decimals())
        local buttons = {
          {label="OK", action=function() return true end},
          {label="Cancel", action=function() return true end},
          {label="Nothing", action=function() return false end},
        }
        form.openDialog("Dialog demo", "This is a demo to show how to use LUA Message Dialog", buttons)        
      end
    },
  }
end

local function wakeup(widget)
  -- print(system.getMemoryUsage().mainStackAvailable)
  -- table.insert(testTabele, {
  --   speed=200,
  --   rssi=50,
  --   RxBatt=22.5,
  --   thr=1024,
  -- })

  local w, h = lcd.getWindowSize()
  if w ~= widget.w then
    widget.w = w
    if w == 800 then isFullScreen = 1 end
    lcd.invalidate()
  end
  if modelName ~= model.name() then
    modelName = model.name()
  end
  if h ~= widget.h then
    widget.h = h
    lcd.invalidate()
  end
  time.wakeup(widget)
  ext.wakeup(widget)
  rx.wakeup(widget)
  counts.wakeup(widget)
  copyright.wakeup(widget)
  gps.wakeup(widget)
  usage.wakeup(widget)
end

local function paint(widget)
  lcd.color(var.bgColor)
  lcd.drawFilledRectangle(0, 0, widget.w, widget.h)

  local left = 296
  local half = 236
  local third = 152
  local forth = 112

  local fix = isFullScreen == 0 and 0 or var.padding
  local yFix = isFullScreen == 0 and 0 or 480 - 316 - var.padding

  util.drawBox(widget, fix, yFix, left, 70 + 36, time.paint)
  util.drawBox(widget, fix, yFix + 114, left, var.modelBitmapHeight + 16, bitmap.paint)

  -- line 1
  util.drawBox(widget, fix + left + var.padding, yFix, half, 106, ext.paint)
  util.drawBox(widget, fix + left + var.padding + half + var.padding, yFix, half, 106, rx.paint)

  -- line 2
  util.drawBox(widget, fix + left + var.padding, yFix + 114, half, 78, ext.paintCell)
  util.drawBox(widget, fix + left + var.padding + half + var.padding, yFix + 114, half, 78, counts.paint)

  -- line 3
  util.drawBox(widget, fix + left + var.padding, yFix + 200, half, 78, gps.paint)
  util.drawBox(widget, fix + left + var.padding + half + var.padding, yFix + 200, half, 78, usage.paint)

  -- line 4
  util.drawBox(widget, fix + left + var.padding, yFix + 286, half * 2 + var.padding, 30, copyright.paint)
  -- message.paint(widget, 400, 200)
  -- lcd.setClipping(400, 200, 120, 20)
end

local function init()
  system.registerWidget({
    key="copilot",
    name="Copilot",
    create=create,
    wakeup=wakeup,
    paint=paint,
    persistent=false,
    title=false,
  })
end

return {init=init}