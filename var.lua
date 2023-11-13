local module = {}

module.MAX = 1024
module.MIN = -1024

module.padding = 8

module.fontWidth = 48
module.dotWidth = 22

module.modelBitmapWidth = 280
module.modelBitmapHeight = 186

module.whiteColor = lcd.RGB(255, 255, 255)
module.blackColor = lcd.RGB(0, 0, 0, 0.8)
module.redColor = lcd.RGB(215, 51, 51)
module.lightRedColor = lcd.RGB(213, 113, 113)
module.yellowColor = lcd.RGB(248, 176, 56)
module.lightYellowColor = lcd.RGB(219, 208, 121)
module.greenColor = lcd.RGB(6, 152, 17)
module.lightGreenColor = lcd.RGB(148, 222, 18)
module.blueColor = lcd.RGB(0, 136, 248)
module.lightBlueColor = lcd.RGB(0, 136, 248)
module.greyColor = lcd.RGB(64, 64, 64)
module.lightGreyColor = lcd.RGB(220, 230, 230)
module.textColor = lcd.GREY(80)
module.themeColor = lcd.themeColor(THEME_FOCUS_COLOR)
module.bgColor = lcd.RGB(0xD0, 0xD0, 0xD0)

return module