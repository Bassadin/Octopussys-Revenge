-- Gwee: graphical user interface module for love2d
-- Author: Michael Carius <michael.a.carius@gmail.com>

local loo = require "Libraries.loo"

local gwee = {}
local groups = {}
local DEFAULT_SKIN = {
    group = {
        font = love.graphics.newFont(12),
        labelcolor = {0xff, 0xff, 0xff, 0xff},
    },

    button = {
        font = love.graphics.newFont(12),
        labelcolor = {0x00, 0x00, 0x00, 0xff},
        color = {0x44, 0x44, 0x44, 0xff},
        hovercolor = {0x88, 0x88, 0x88, 0xff},
        bordercolor = {0x66, 0x66, 0x66, 0xff}
    },

    textfield = {
        font = love.graphics.newFont(12),
        labelcolor = {0xff, 0xff, 0xff, 0xff},
        labelgap = 5,
        textcolor = {0x00, 0x00, 0x00, 0xff},
        margins = {left = 2, right = 2},
        cursorheight = 0.9,
        color = {0xff, 0xff, 0xff, 0xff},
        bordercolor = {0xaa, 0xaa, 0xaa, 0xff}
    },

    checkbox = {
        font = love.graphics.newFont(12),
        labelcolor = {0xff, 0xff, 0xff, 0xff},
        color = {0xff, 0xff, 0xff, 0xff},
        bordercolor = {0xaa, 0xaa, 0xaa, 0xff},
        markcolor = {0x00, 0x00, 0x00, 0xff},
        markstyle = "circle",
        marksize = 0.6
    },

    slider = {
        font = love.graphics.newFont(12),
        labelcolor = {0xff, 0xff, 0xff, 0xff},
        barcolor = {0x44, 0x44, 0x44, 0x44, 0xff},
        barsize = 0.5,
        slidercolor = {0x88, 0x88, 0x88, 0xff},
        sliderwidth = 0.1,
    },
}

--- A group of widgets.
-- gwee.Groups are meant to hold a set of widgets with a similar purpose. They
-- delegate all love callbacks to their child widgets (which can include other
-- groups), their child widgets are automatically arranged, they can be
-- skinned, and place a label above their bounding box.
-- @class table
-- @name gwee.Group
-- @field enabled Controls whether love2d callback accelerators will affect
-- this gwee.Group.
gwee.Group = loo.class()

--- gwee.Group constructor.
-- @param box The bounding box of the group.
-- @param layout The layout to use.
-- @param label The header to display above the widgets.
-- @param skin The skin customizations to use (optional).
function gwee.Group:initialize(box, layout, label, skin)
    self.box = box
    self.layout = layout
    self.skin = skin or DEFAULT_SKIN
    self.label = label
    self.widgets = {}
    table.insert(groups, self)
    self.enabled = true
end

--- Add a widget to a group.
-- @param widget An instance of one of the widget classes.
-- @return The widget passed in. Convenience.
function gwee.Group:add(widget)
    table.insert(self.widgets, widget)
    widget.skin = self.skin
    self.layout:configure(self.box, self.widgets)
    return widget
end

--- love2d callback.
-- @param key As passed to love.keypressed().
-- @param unicode As passed to love.keypressed().
function gwee.Group:keypressed(key, unicode)
    for _, widget in ipairs(self.widgets) do
        if widget.keypressed then
            widget:keypressed(key, unicode)
        end
    end
end

--- love2d callback.
-- @param x As passed to love.mousepressed().
-- @param y As passed to love.mousepressed().
-- @param button As passed to love.mousepressed().
function gwee.Group:mousepressed(x, y, button)
    for _, widget in ipairs(self.widgets) do
        if widget.mousepressed then
            widget:mousepressed(x, y, button)
        end
    end
end

--- love2d callback.
-- @param x As passed to love.mousereleased().
-- @param y As passed to love.mousereleased().
-- @param button As passed to love.mousereleased().
function gwee.Group:mousereleased(x, y, button)
    for _, widget in ipairs(self.widgets) do
        if widget.mousereleased then
            widget:mousereleased(x, y, button)
        end
    end
end

--- love2d callback.
-- @param dt As passed to love.update().
function gwee.Group:update(dt)
    for _, widget in ipairs(self.widgets) do
        if widget.update then
            widget:update(dt)
        end
    end
end

--- love2d callback.
function gwee.Group:draw()
    local style = self.skin.group
    love.graphics.setFont(style.font)
    love.graphics.setColor(style.labelcolor)
    love.graphics.print(self.label, self.box.x, self.box.y - 20)
    for _, widget in ipairs(self.widgets) do
        if widget.draw then
            widget:draw();
        end
    end
end

--- A clickable button.
-- Invokes a callback function when clicked.
-- @class table
-- @name gwee.Button
gwee.Button = loo.class()

--- gwee.Button constructor.
-- @param callback The callback function to invoke when clicked.
-- @param label The text label to place on the button.
function gwee.Button:initialize(callback, label)
    self.callback = callback
    self.label = label
    self.box = gwee.Box(0, 0, 0, 0)
end

function gwee.Button:keypressed(key, unicode)
    if key == "return" and self.box.focused then
        self.callback()
    end
end

function gwee.Button:mousepressed(x, y, button)
    self.box:mousepressed(x, y, button)
    if self.box.focused and button == "l" then
        self.callback()
    end
end

function gwee.Button:mousereleased(x, y, button)
    self.box:mousereleased(x, y, button)
end

function gwee.Button:update(dt)
    self.box:update(dt)
end

function gwee.Button:draw()
    local style = self.skin.button

    -- Draw the box
    if self.box.hover then
        love.graphics.setColor(style.hovercolor)
    else
        love.graphics.setColor(style.color)
    end
    love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w,
        self.box.h)

    -- Draw the border
    -- 2px hack
    love.graphics.setLineWidth(2)
    love.graphics.setColor(style.bordercolor)
    love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w,
        self.box.h)

    -- Draw the label
    local labelX = self.box.x
        + (self.box.w - style.font:getWidth(self.label)) / 2
    local labelY = self.box.y + (self.box.h - style.font:getHeight()) / 2
    love.graphics.setColor(style.labelcolor)
    love.graphics.setFont(style.font)
    love.graphics.print(self.label, labelX, labelY)
end

--- A one-line text field.
-- Supports the following special keys: backspace, delete, home, end, left,
-- right
-- @class table
-- @name gwee.TextField
-- @field text The text currently in the buffer.
gwee.TextField = loo.class()

--- gwee.TextField constructor.
-- @param label The label to place beside the input box.
function gwee.TextField:initialize(label)
    self.label = label
    self.box = gwee.Box(0, 0, 0, 0)
    self.text = ""
    self.pos = 0
end

function gwee.TextField:keypressed(key, unicode)
    if self.box.focused then
        if key == "backspace" then
            self:backspace()
        elseif key == "delete" then
            self:delete()
        elseif key == "home" then
            self:goToBeginning()
        elseif key == "end" then
            self:goToEnd()
        elseif key == "left" then
            self:left()
        elseif key == "right" then
            self:right()
        -- assume char length of 1 is a printable char
        elseif key:len() == 1 then
            self:insertCharacter(string.char(unicode))
        end
    end
end

function gwee.TextField:insertCharacter(character)
    self.text = self.text:sub(1, self.pos) .. character
        .. self.text:sub(self.pos + 1)
    self.pos = self.pos + 1
end

function gwee.TextField:backspace()
    if self.pos > 0 then
        self.text = self.text:sub(1, self.pos - 1)
            .. self.text:sub(self.pos + 1)
        self.pos = self.pos - 1
    end
end

function gwee.TextField:delete()
    if self.pos < self.text:len() then
        self.text = self.text:sub(1, self.pos)
            .. self.text:sub(self.pos + 2)
    end
end

function gwee.TextField:goToEnd()
    self.pos = self.text:len()
end

function gwee.TextField:goToBeginning()
    self.pos = 0
end

function gwee.TextField:left()
    if self.pos > 0 then
        self.pos = self.pos - 1
    end
end

function gwee.TextField:right()
    if self.pos < self.text:len() then
        self.pos = self.pos + 1
    end
end

function gwee.TextField:mousepressed(x, y, button)
    self.box:mousepressed(x, y, button)
end

function gwee.TextField:draw()
    local style = self.skin.textfield

    -- Draw the label
    local labelX = self.box.x - style.font:getWidth(self.label)
        - style.labelgap
    local labelY = self.box.y + (self.box.h - style.font:getHeight()) / 2
    love.graphics.setColor(style.labelcolor)
    love.graphics.setFont(style.font)
    love.graphics.print(self.label, labelX, labelY)

    -- Draw the box
    love.graphics.setColor(style.color)
    love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w,
        self.box.h)

    -- Draw the border
    -- 2px hack
    love.graphics.setLineWidth(2)
    love.graphics.setColor(style.bordercolor)
    love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w,
        self.box.h)

    -- Draw the text
    -- Scissoring means no fancy clipping logic
    -- (clips to a box smaller than the textbox by 2px on either side)
    love.graphics.setScissor(self.box.x + style.margins.left, self.box.y,
        self.box.w - (style.margins.left + style.margins.right),
        self.box.h)

    local textWidth = style.font:getWidth(self.text:sub(1, self.pos))
    local textX
    if textWidth > self.box.w then
        -- Right-justify to pos if text is longer than the box
        textX = (self.box.x + self.box.w) - (textWidth - self.box.w)
            - self.box.w - style.margins.right
    else
        -- Left-justify otherwise
        textX = self.box.x + style.margins.left
    end
    -- Text is at the same level as the label
    local textY = labelY
    love.graphics.setColor(style.textcolor)
    love.graphics.setFont(style.font)
    love.graphics.print(self.text, textX, textY)

    -- Disable scissoring
    love.graphics.setScissor()

    -- Draw the cursor
    if self.box.focused then
        local cursorHeight = self.box.h * style.cursorheight
        local cursorVertices = {
            textX + textWidth, self.box.y + (self.box.h - cursorHeight) / 2,
            textX + textWidth, self.box.y + cursorHeight
        }

        -- 2px hack
        love.graphics.setLineWidth(2)
        love.graphics.setColor(style.textcolor)
        love.graphics.line(cursorVertices)
    end
end

--- A check box.
-- Toggle on and off with mouse clicks.
-- @class table
-- @name gwee.CheckBox
-- @field checked Whether the box is currently checked.
gwee.CheckBox = loo.class()

--- gwee.CheckBox constructor.
-- @param label The label to place beside the check box.
function gwee.CheckBox:initialize(label)
    self.label = label
    self.box = gwee.Box(0, 0, 0, 0)
    self.checked = false
end

function gwee.CheckBox:keypressed(key, unicode)
    if key == " " and self.box.focused then
        self.checked = not self.checked
    end
end

function gwee.CheckBox:mousepressed(x, y, button)
    self.box:mousepressed(x, y, button)
    if self.box.focused then
        self.checked = not self.checked
    end
end

function gwee.CheckBox:draw()
    local style = self.skin.checkbox

    -- Hack -- it's a *box*, so we adjust to the biggest square we can get
    -- away with
    local boxX, boxY, boxSize
    if self.box.w < self.box.h then
        boxSize = self.box.w
        boxX = self.box.x
        boxY = self.box.y + (self.box.h - boxSize) / 2
    else
        boxSize = self.box.h
        boxX = self.box.x
        boxY = self.box.y
    end

    -- Draw the label
    local labelX = self.box.x - style.font:getWidth(self.label) - 5
    local labelY = self.box.y + (self.box.h - style.font:getHeight()) / 2
    love.graphics.setColor(style.labelcolor)
    love.graphics.setFont(style.font)
    love.graphics.print(self.label, labelX, labelY)

    -- Draw the box
    love.graphics.setColor(style.color)
    love.graphics.rectangle("fill", boxX, boxY, boxSize, boxSize)

    -- Draw the border
    -- 2px hack
    love.graphics.setLineWidth(2)
    love.graphics.setColor(style.bordercolor)
    love.graphics.rectangle("line", boxX, boxY, boxSize, boxSize)

    -- Draw the mark
    if self.checked then
        love.graphics.setColor(style.markcolor)
        if style.markstyle == "circle" then
            local markCenterX = boxX + boxSize / 2
            local markCenterY = boxY + boxSize / 2
            local markRadius = (boxSize / 2) * style.marksize
            local numSegments = 20
            love.graphics.circle("fill", markCenterX, markCenterY,
                markRadius, numSegments)
        elseif style.markstyle == "square" then
            local markSize = boxSize * style.marksize
            local markX = boxX + (boxSize - markSize) / 2
            local markY = boxY + (boxSize - markSize) / 2
            love.graphics.rectangle("fill", markX, markY, markSize,
                markSize)
        end
    end
end

--- A value slider.
-- Drag the slider along the bar to change the value.
-- @class table
-- @name gwee.Slider
-- @field value The current value on the slider.
gwee.Slider = loo.class()

--- gwee.Slider constructor.
-- @param min The minimum value allowed by the slider.
-- @param max The maximum value allowed by the slider.
-- @param label The label to place beside the slider.
function gwee.Slider:initialize(min, max, label)
    self.min = min
    self.range = max - min
    self.label = label
    self.box = gwee.Box(0, 0, 0, 0)
    self.value = min + self.range / 2
end

function gwee.Slider:keypressed(key, unicode)
    if self.box.focused then
        if key == "left" then
            self:less()
        elseif key == "right" then
            self:more()
        end
    end
end

function gwee.Slider:less()
    self:addValue(-self.range / 10)
end

function gwee.Slider:more()
    self:addValue(self.range / 10)
end

function gwee.Slider:addValue(amount)
    self.value = self:clamp(self.value + amount)
end

function gwee.Slider:mousepressed(x, y, button)
    self.box:mousepressed(x, y, button)
    if self.box.focused then
        self.value = self:valueForMousePosition(x)
    end
end

function gwee.Slider:mousereleased(x, y, button)
    if self.box.dragging then
        self.value = self:valueForMousePosition(x)
    end
    self.box:mousereleased(x, y, button)
end

function gwee.Slider:update(dt)
    if self.box.dragging then
        self.value = self:valueForMousePosition(love.mouse.getX())
    end
end

function gwee.Slider:valueForMousePosition(mouseX)
    local percent = (mouseX - self.box.x) / self.box.w
    return self:clamp(self.min + self.range * percent)
end

function gwee.Slider:clamp(value)
    if value > self.min + self.range then
        return self.min + self.range
    elseif value < self.min then
        return self.min
    else
        return value
    end
end

function gwee.Slider:draw()
    local style = self.skin.slider

    -- Draw the label
    local labelX = self.box.x - style.font:getWidth(self.label) - 5
    local labelY = self.box.y + (self.box.h - style.font:getHeight()) / 2
    love.graphics.setColor(style.labelcolor)
    love.graphics.setFont(style.font)
    love.graphics.print(self.label, labelX, labelY)

    -- Draw the bar
    local barHeight = self.box.h * style.barsize
    local barY = self.box.y + (self.box.h - barHeight) / 2
    love.graphics.setColor(style.barcolor)
    love.graphics.rectangle("fill", self.box.x, barY, self.box.w, barHeight)

    -- Draw the slider
    local percent = (self.value - self.min) / self.range
    local sliderX = self.box.x + self.box.w * percent
    local sliderWidth = self.box.w * style.sliderwidth
    love.graphics.setColor(style.slidercolor)
    love.graphics.rectangle("fill", sliderX, self.box.y, sliderWidth,
        self.box.h)
end

--- A bounding box.
-- Used to specify areas on the screen for layouts.
-- @class table
-- @name gwee.Box
gwee.Box = loo.class()

--- gwee.Box constructor.
-- @param x The horizontal position.
-- @param y The vertical position.
-- @param w The width.
-- @param h The height.
function gwee.Box:initialize(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.hover = false
    self.focused = false
    self.dragging = false
end

function gwee.Box:mousepressed(x, y, button)
    if self:contains(x, y) then
        self.focused = true
        self.dragging = true
    else
        self.focused = false
    end
end

function gwee.Box:mousereleased(x, y, button)
    if self.dragging then
        self.dragging = false
    end
end

function gwee.Box:update(dt)
    local x, y = love.mouse.getPosition()
    if self:contains(x, y) then
        self.hover = true
    else
        self.hover = false
    end
end

function gwee.Box:contains(x, y)
    local collideX = x > self.x and x < self.x + self.w
    local collideY = y > self.y and y < self.y + self.h
    return collideX and collideY
end

--- Stacks widgets vertically.
-- @class table
-- @name gwee.VerticalLayout
gwee.VerticalLayout = loo.class()

--- gwee.VerticalLayout constructor.
-- @param spacing The amount of space between each widget.
function gwee.VerticalLayout:initialize(spacing)
    self.spacing = spacing or 0
end

function gwee.VerticalLayout:configure(box, widgets)
    local widgetWidth = box.w - self.spacing * 2
    local widgetHeight = (box.h - self.spacing * (#widgets + 1)) / #widgets
    local widgetX = box.x + self.spacing
    local widgetY = box.y + self.spacing
    for _, widget in ipairs(widgets) do
        widget.box = gwee.Box(widgetX, widgetY, widgetWidth, widgetHeight)
        widgetY = widgetY + self.spacing + widgetHeight
    end
end

--- Load a skin from a directory.
-- @param skinName The name of the directory to look in.
-- @return The skin, to be passed to gwee.Group:initialize().
function gwee.loadSkin(skinName)
    -- load the skin itself
    local skin = love.filesystem.load(skinName .. "/style.lua")()

    -- load resources specified in the skin
    skin.group.font = tryToLoadFont(skinName .. "/" .. skin.group.font,
        skin.group.fontsize)
    skin.button.font = tryToLoadFont(skinName .. "/" .. skin.button.font,
        skin.button.fontsize)
    skin.textfield.font = tryToLoadFont(skinName .. "/" .. skin.textfield.font,
        skin.textfield.fontsize)
    skin.checkbox.font = tryToLoadFont(skinName .. "/" .. skin.checkbox.font,
        skin.checkbox.fontsize)
    skin.slider.font = tryToLoadFont(skinName .. "/" .. skin.slider.font,
        skin.slider.fontsize)

    -- set defaults
    for widgetClass, defaultStyle in pairs(DEFAULT_SKIN) do
        local skinStyle = skin[widgetClass]
        for property, default in pairs(defaultStyle) do
            if not skinStyle[property] then
                skinStyle[property] = default
            end
        end
    end

    return skin
end

function tryToLoadFont(fontName, fontSize)
    if fontName and fontSize then
        return love.graphics.newFont(fontName, fontSize)
    end
end

--- love2d accelerator.
-- Invokes keypressed() on all enabled gwee.Groups.
-- @param key As passed to love.keypressed().
-- @param unicode As passed to love.keypressed().
function gwee.keypressed(key, unicode)
    for _, g in ipairs(groups) do
        if g.enabled then
            g:keypressed(key, unicode)
        end
    end
end

--- love2d accelerator.
-- Invokes mousepressed() on all enabled gwee.Groups.
-- @param x As passed to love.mousepressed().
-- @param y As passed to love.mousepressed().
-- @param button As passed to love.mousepressed().
function gwee.mousepressed(x, y, l)
    for _, g in ipairs(groups) do
        if g.enabled then
            g:mousepressed(x, y, l)
        end
    end
end

--- love2d accelerator.
-- Invokes mousereleased() on all enabled gwee.Groups.
-- @param x As passed to love.mousepressed().
-- @param y As passed to love.mousepressed().
-- @param button As passed to love.mousepressed().
function gwee.mousereleased(x, y, button)
    for _, g in ipairs(groups) do
        if g.enabled then
            g:mousereleased(x, y, button)
        end
    end
end

--- love2d accelerator.
-- Invokes update() on all enabled gwee.Groups.
-- @param dt As passed to love.update().
function gwee.update(dt)
    for _, g in ipairs(groups) do
        if g.enabled then
            g:update(dt)
        end
    end
end

--- love2d accelerator.
-- Invokes draw() on all enabled gwee.Groups.
function gwee.draw()
    -- save old values so we don't disrupt anything
    local color = {love.graphics.getColor()}
    local font = love.graphics.getFont()

    for _, g in ipairs(groups) do
        if g.enabled then
            g:draw()
        end
    end

    -- restore old values
    love.graphics.setColor(color)
    love.graphics.setFont(font)
end

return gwee
