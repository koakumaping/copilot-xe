local module = {}

local modelMask = lcd.loadMask('./bitmaps/model-mask.png')

function module.paint(widget, x, y)
  if widget.bitmap ~= nil then
    lcd.drawBitmap(x, y - 4, widget.bitmap, var.modelBitmapWidth, var.modelBitmapHeight)
    lcd.color(lcd.RGB(225, 225, 225))
    lcd.drawMask(x, y - 4, modelMask)
  end
end

return module