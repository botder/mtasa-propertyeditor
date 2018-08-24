--
-- ColorPicker
--
local ColorPicker = {}
ColorPicker.__index = ColorPicker

local function round(value)
    return math.floor(value + 0.5)
end

local function getARGBFromString(color)
    local a, r, g, b = color:match("(%x%x)(%x%x)(%x%x)(%x%x)")

    if a then
        return tonumber(a, 16), tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
    else
        return 255, 255, 255, 255
    end
end

local function getPreviewText(a, r, g, b)
    return ("A: %3d\nR: %3d\nG: %3d\nB: %3d\n\n%02X%02X%02X%02X"):format(a, r, g, b, a, r, g, b)
end

local function getColorStringARGB(a, r, g, b)
    return ("%02X%02X%02X%02X"):format(a, r, g, b)
end

local function getImageColoursText(a, r, g, b)
    a = a or 255
    local argb = ("%02x%02x%02x%02x"):format(a, r, g, b)
    return ("tl:%s tr:%s bl:%s br:%s"):format(argb, argb, argb, argb)
end

local function hsv2rgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local switch = i % 6

    if switch == 0 then
        r = v; g = t; b = p
    elseif switch == 1 then
        r = q; g = v; b = p
    elseif switch == 2 then
        r = p; g = v; b = t
    elseif switch == 3 then
        r = p; g = q; b = v
    elseif switch == 4 then
        r = t; g = p; b = v
    elseif switch == 5 then
        r = v; g = p; b = q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function rgb2hsv(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h
    local v = max
    local d = max - min
    local s = (max == 0) and 0 or (d / max)

    if max == min then
        h = 0
    elseif max == r then
        h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
        h = (b - r) / d + 2
    elseif max == b then
        h = (r - g) / d + 4
    end

    h = h / 6
    return h, s, v
end

local function guiSetSliderPosition(element, x, width, progress)
    progress = math.max(0.0, math.min(1.0, progress))
    x = x + (width * progress)
    local _, y = guiGetPosition(element, false)
    guiSetPosition(element, x - 4, y, false)
end

function guiCreateColorPicker(x, y, width, parent, value, callback)
    local self = setmetatable({}, ColorPicker)
    self.callback = callback
    self.x = x
    self.y = y

    local a, r, g, b = getARGBFromString(value)
    local h, s, v = rgb2hsv(r, g, b)

    self.color = {
        a = a,
        r = r,
        g = g,
        b = b,
        h = h,
        s = s,
        v = v,
    }

    self.labels = {}
    self.labels.h = guiCreateLabel(x + 155, y + 3, 32, 20, round(h * 360) .."°", false, parent)
    self.labels.s = guiCreateLabel(x + 155, y + 28, 32, 20, round(s * 100) .."%", false, parent)
    self.labels.v = guiCreateLabel(x + 155, y + 53, 32, 20, round(v * 100) .."%", false, parent)
    self.labels.a = guiCreateLabel(x + 155, y + 78, 32, 20, a, false, parent)
    self.labels.row = {}
    self.labels.row.h = guiCreateLabel(x, y + 2, 20, 20, "H:", false, parent)
    self.labels.row.s = guiCreateLabel(x, y + 27, 20, 20, "S:", false, parent)
    self.labels.row.v = guiCreateLabel(x, y + 52, 20, 20, "V:", false, parent)
    self.labels.row.a = guiCreateLabel(x, y + 77, 20, 20, "A:", false, parent)
    guiSetFont(self.labels.h, "default-small")
    guiSetFont(self.labels.s, "default-small")
    guiSetFont(self.labels.v, "default-small")
    guiSetFont(self.labels.a, "default-small")

    self.hue = {}
    self.hue.fg = guiCreateStaticImage(x + 20, y, 128, 20, "assets/hue.png", false, parent)
    self.hue.slider = guiCreateStaticImage(x + 20, y, 8, 20, "assets/slider.png", false, parent)
    guiSetSliderPosition(self.hue.slider, x + 20, 128, h)
    guiSetEnabled(self.hue.slider, false)
    
    addEventHandler("onClientGUIClick", self.hue.fg, bind(self, self._clickHue), false)
    addEventHandler("onClientGUIClick", self.labels.row.h, bind(self, self._minHue), false)
    addEventHandler("onClientGUIClick", self.labels.h, bind(self, self._maxHue), false)

    local imageColors = getImageColoursText(255, hsv2rgb(self.color.h, 1, 1))

    self.saturation = {}
    self.saturation.bg = guiCreateStaticImage(x + 20, y + 25, 128, 20, "assets/dot.png", false, parent)
    guiSetProperty(self.saturation.bg, "ImageColours", imageColors)
    self.saturation.fg = guiCreateStaticImage(x + 20, y + 25, 128, 20, "assets/saturation.png", false, parent)
    self.saturation.slider = guiCreateStaticImage(x + 20, y + 25, 8, 20, "assets/slider.png", false, parent)
    guiSetSliderPosition(self.saturation.slider, x + 20, 128, s)
    guiSetEnabled(self.saturation.slider, false)

    addEventHandler("onClientGUIClick", self.saturation.fg, bind(self, self._clickSaturation), false)
    addEventHandler("onClientGUIClick", self.labels.row.s, bind(self, self._minSaturation), false)
    addEventHandler("onClientGUIClick", self.labels.s, bind(self, self._maxSaturation), false)

    self.value = {}
    self.value.bg = guiCreateStaticImage(x + 20, y + 50, 128, 20, "assets/dot.png", false, parent)
    guiSetProperty(self.value.bg, "ImageColours", imageColors)
    self.value.fg = guiCreateStaticImage(x + 20, y + 50, 128, 20, "assets/value.png", false, parent)
    self.value.slider = guiCreateStaticImage(x + 20, y + 50, 8, 20, "assets/slider.png", false, parent)
    guiSetSliderPosition(self.value.slider, x + 20, 128, v)
    guiSetEnabled(self.value.slider, false)

    addEventHandler("onClientGUIClick", self.value.fg, bind(self, self._clickValue), false)
    addEventHandler("onClientGUIClick", self.labels.row.v, bind(self, self._minValue), false)
    addEventHandler("onClientGUIClick", self.labels.v, bind(self, self._maxValue), false)

    self.alpha = {}
    self.alpha.bg = guiCreateStaticImage(x + 20, y + 75, 128, 20, "assets/dot.png", false, parent)
    guiSetProperty(self.alpha.bg, "ImageColours", imageColors)
    self.alpha.fg = guiCreateStaticImage(x + 20, y + 75, 128, 20, "assets/alpha.png", false, parent)
    self.alpha.slider = guiCreateStaticImage(x + 20, y + 75, 8, 20, "assets/slider.png", false, parent)
    guiSetSliderPosition(self.alpha.slider, x + 20, 128, a / 255)
    guiSetEnabled(self.alpha.slider, false)

    addEventHandler("onClientGUIClick", self.alpha.fg, bind(self, self._clickAlpha), false)
    addEventHandler("onClientGUIClick", self.labels.row.a, bind(self, self._minAlpha), false)
    addEventHandler("onClientGUIClick", self.labels.a, bind(self, self._maxAlpha), false)

    self.preview = {}
    self.preview.frame = guiCreateButton(x + 185, y, 95, 95, "", false, parent)
    self.preview.image = guiCreateStaticImage(5, 5, 85, 85, "assets/dot.png", false, self.preview.frame)
    local previewText = getPreviewText(a, r, g, b)
    self.preview.shadow = guiCreateLabel(6, 6, 86, 86, previewText, false, self.preview.frame)
    self.preview.label = guiCreateLabel(5, 5, 85, 85, previewText, false, self.preview.frame)
    guiSetProperty(self.preview.image, "ImageColours", getImageColoursText(a, r, g, b))
    guiSetEnabled(self.preview.shadow, false)
    guiSetEnabled(self.preview.label, false)
    guiSetEnabled(self.preview.frame, false)
    guiSetFont(self.preview.shadow, "default-small")
    guiSetFont(self.preview.label, "default-small")
    guiLabelSetColor(self.preview.shadow, 0, 0, 0)
    guiLabelSetColor(self.preview.label, 255, 255, 255)
    guiLabelSetHorizontalAlign(self.preview.shadow, "center")
    guiLabelSetVerticalAlign(self.preview.shadow, "center")
    guiLabelSetHorizontalAlign(self.preview.label, "center")
    guiLabelSetVerticalAlign(self.preview.label, "center")

    return self
end

--
-- Public
--
function ColorPicker:destroy()
    destroyElement(self.labels.h)
    destroyElement(self.labels.s)
    destroyElement(self.labels.v)
    destroyElement(self.labels.a)
    destroyElement(self.labels.row.h)
    destroyElement(self.labels.row.s)
    destroyElement(self.labels.row.v)
    destroyElement(self.labels.row.a)
    destroyElement(self.hue.fg)
    destroyElement(self.hue.slider)
    destroyElement(self.saturation.bg)
    destroyElement(self.saturation.fg)
    destroyElement(self.saturation.slider)
    destroyElement(self.value.bg)
    destroyElement(self.value.fg)
    destroyElement(self.value.slider)
    destroyElement(self.alpha.bg)
    destroyElement(self.alpha.fg)
    destroyElement(self.alpha.slider)
    destroyElement(self.preview.frame)
end

function ColorPicker:setVisible(visible)
    guiSetVisible(self.labels.h, visible)
    guiSetVisible(self.labels.s, visible)
    guiSetVisible(self.labels.v, visible)
    guiSetVisible(self.labels.a, visible)
    guiSetVisible(self.labels.row.h, visible)
    guiSetVisible(self.labels.row.s, visible)
    guiSetVisible(self.labels.row.v, visible)
    guiSetVisible(self.labels.row.a, visible)
    guiSetVisible(self.hue.fg, visible)
    guiSetVisible(self.hue.slider, visible)
    guiSetVisible(self.saturation.bg, visible)
    guiSetVisible(self.saturation.fg, visible)
    guiSetVisible(self.saturation.slider, visible)
    guiSetVisible(self.value.bg, visible)
    guiSetVisible(self.value.fg, visible)
    guiSetVisible(self.value.slider, visible)
    guiSetVisible(self.alpha.bg, visible)
    guiSetVisible(self.alpha.fg, visible)
    guiSetVisible(self.alpha.slider, visible)
    guiSetVisible(self.preview.frame, visible)
end

function ColorPicker:setColor(color)
    local a, r, g, b = getARGBFromString(color)
    self.color.a = a
    self.color.h, self.color.s, self.color.v = rgb2hsv(r, g, b)
    self:_updateColor()
    guiSetSliderPosition(self.hue.slider, self.x + 20, 128, self.color.h)
    guiSetSliderPosition(self.saturation.slider, self.x + 20, 128, self.color.s)
    guiSetSliderPosition(self.value.slider, self.x + 20, 128, self.color.v)
    guiSetSliderPosition(self.alpha.slider, self.x + 20, 128, self.color.a / 255)
    guiSetText(self.labels.h, round(self.color.h * 360) .."°")
    guiSetText(self.labels.s, round(self.color.s * 100) .."%")
    guiSetText(self.labels.v, round(self.color.v * 100) .."%")
    guiSetText(self.labels.a, round(self.color.a))
    self.callback(getColorStringARGB(a, r, g, b))
end

function ColorPicker:move(x, y)
    guiSetPosition(self.labels.h, x + 155, y + 3, false)
    guiSetPosition(self.labels.s, x + 155, y + 28, false)
    guiSetPosition(self.labels.v, x + 155, y + 53, false)
    guiSetPosition(self.labels.a, x + 155, y + 78, false)
    guiSetPosition(self.labels.row.h, x, y + 2, false)
    guiSetPosition(self.labels.row.s, x, y + 27, false)
    guiSetPosition(self.labels.row.v, x, y + 52, false)
    guiSetPosition(self.labels.row.a, x, y + 77, false)
    guiSetPosition(self.hue.fg, x + 20, y, false)
    guiSetPosition(self.hue.slider, x + 20, y, false)
    guiSetSliderPosition(self.hue.slider, x + 20, 128, self.color.h)
    guiSetPosition(self.saturation.bg, x + 20, y + 25, false)
    guiSetPosition(self.saturation.fg, x + 20, y + 25, false)
    guiSetPosition(self.saturation.slider, x + 20, y + 25, false)
    guiSetSliderPosition(self.saturation.slider, x + 20, 128, self.color.s)
    guiSetPosition(self.value.bg, x + 20, y + 50, false)
    guiSetPosition(self.value.fg, x + 20, y + 50, false)
    guiSetPosition(self.value.slider, x + 20, y + 50, false)
    guiSetSliderPosition(self.value.slider, x + 20, 128, self.color.v)
    guiSetPosition(self.alpha.bg, x + 20, y + 75, false)
    guiSetPosition(self.alpha.fg, x + 20, y + 75, false)
    guiSetPosition(self.alpha.slider, x + 20, y + 75, false)
    guiSetSliderPosition(self.alpha.slider, x + 20, 128, self.color.a)
    guiSetPosition(self.preview.frame, x + 185, y, false)

    self.x = x
    self.y = y
end

--
-- Private
--
function ColorPicker:_updateColor()
    local r, g, b = hsv2rgb(self.color.h, self.color.s, self.color.v)
    local a = self.color.a
    self.color.r, self.color.g, self.color.b = r, g, b
    
    local previewText = getPreviewText(a, r, g, b)
    guiSetText(self.preview.shadow, previewText)
    guiSetText(self.preview.label, previewText)
    
    local previewImageColors = getImageColoursText(a, r, g, b)
    guiSetProperty(self.preview.image, "ImageColours", previewImageColors)

    local imageColors = getImageColoursText(255, hsv2rgb(self.color.h, 1, 1))
    guiSetProperty(self.saturation.bg, "ImageColours", imageColors)
    guiSetProperty(self.value.bg, "ImageColours", imageColors)
    guiSetProperty(self.alpha.bg, "ImageColours", imageColors)

    self.callback(getColorStringARGB(a, r, g, b))
end

function ColorPicker:_clickHue(_, _, absX, absY)
    guiBringToFront(self.hue.slider)
    absX, absY = guiGetRelativePosition(source, absX, absY)
    self.color.h = absX / 128
    guiSetSliderPosition(self.hue.slider, self.x + 20, 128, self.color.h)
    guiSetText(self.labels.h, round(self.color.h * 360) .."°")
    self:_updateColor()
end

function ColorPicker:_clickSaturation(_, _, absX, absY)
    guiBringToFront(self.saturation.slider)
    absX, absY = guiGetRelativePosition(source, absX, absY)
    self.color.s = absX / 128
    guiSetSliderPosition(self.saturation.slider, self.x + 20, 128, self.color.s)
    guiSetText(self.labels.s, round(self.color.s * 100) .."%")
    self:_updateColor()
end

function ColorPicker:_clickValue(_, _, absX, absY)
    guiBringToFront(self.value.slider)
    absX, absY = guiGetRelativePosition(source, absX, absY)
    self.color.v = absX / 128
    guiSetSliderPosition(self.value.slider, self.x + 20, 128, self.color.v)
    guiSetText(self.labels.v, round(self.color.v * 100) .."%")
    self:_updateColor()
end

function ColorPicker:_clickAlpha(_, _, absX, absY)
    guiBringToFront(self.alpha.slider)
    absX, absY = guiGetRelativePosition(source, absX, absY)
    local ratio = absX / 128
    guiSetSliderPosition(self.alpha.slider, self.x + 20, 128, ratio)
    self.color.a = ratio * 255
    guiSetText(self.labels.a, round(self.color.a))
    self:_updateColor()
end

function ColorPicker:_minHue()
    self.color.h = 0.0
    guiSetSliderPosition(self.hue.slider, self.x + 20, 128, 0.0)
    guiSetText(self.labels.h, "0°")
    self:_updateColor()
end

function ColorPicker:_minSaturation()
    self.color.s = 0.0
    guiSetSliderPosition(self.saturation.slider, self.x + 20, 128, 0.0)
    guiSetText(self.labels.s, "0%")
    self:_updateColor()
end

function ColorPicker:_minValue()
    self.color.v = 0.0
    guiSetSliderPosition(self.value.slider, self.x + 20, 128, 0.0)
    guiSetText(self.labels.v, "0%")
    self:_updateColor()
end

function ColorPicker:_minAlpha()
    guiSetSliderPosition(self.alpha.slider, self.x + 20, 128, 0.0)
    self.color.a = 0
    guiSetText(self.labels.a, "0")
    self:_updateColor()
end

function ColorPicker:_maxHue()
    self.color.h = 1.0
    guiSetSliderPosition(self.hue.slider, self.x + 20, 128, 1.0)
    guiSetText(self.labels.h, "360°")
    self:_updateColor()
end

function ColorPicker:_maxSaturation()
    self.color.s = 1.0
    guiSetSliderPosition(self.saturation.slider, self.x + 20, 128, 1.0)
    guiSetText(self.labels.s, "100%")
    self:_updateColor()
end

function ColorPicker:_maxValue()
    self.color.v = 1.0
    guiSetSliderPosition(self.value.slider, self.x + 20, 128, 1.0)
    guiSetText(self.labels.v, "100%")
    self:_updateColor()
end

function ColorPicker:_maxAlpha()
    guiSetSliderPosition(self.alpha.slider, self.x + 20, 128, 1.0)
    self.color.a = 255
    guiSetText(self.labels.a, "255")
    self:_updateColor()
end
