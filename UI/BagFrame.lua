-- BagFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/20/2019, 3:32:48 AM

---- LUA
local ipairs = ipairs
local select = select

---- WOW
local CreateFrame = CreateFrame

---@type ns
local ns = select(2, ...)

---@class tdBag2BagFrame
local BagFrame = ns.Addon:NewClass('UI.BagFrame', 'Frame')
BagFrame.SPACING = 3

---@param meta tdBag2FrameMeta
function BagFrame:Constructor(_, meta)
    local bags = meta.bags
    local spacing = self.SPACING
    local button, prevButton
    local width, height = 0, 0

    for i, bag in ipairs(bags) do
        local template = ns.IsKeyring(bag) and 'tdBag2KeyringTemplate' or 'tdBag2BagTemplate'
        button = ns.UI.Bag:Bind(CreateFrame('Button', nil, self, template), meta, bag)
        if i == 1 then
            button:SetPoint('LEFT')
        else
            button:SetPoint('LEFT', prevButton, 'RIGHT', spacing, 0)
        end
        prevButton = button
        width = width + button:GetWidth() + spacing
    end
    if button then
        width = width - spacing
    end

    self:SetSize(width, button:GetHeight())
end
