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
---@field protected meta tdBag2FrameMeta
local BagFrame = ns.Addon:NewClass('UI.BagFrame', 'Frame')
BagFrame.SPACING = 3

---@param meta tdBag2FrameMeta
function BagFrame:Constructor(_, meta)
    self.meta = meta
    self:SetScript('OnShow', self.OnShow)
end

function BagFrame:OnShow()
    self:SetScript('OnShow', nil)
    self:Update()
end

function BagFrame:Update()
    local spacing = self.SPACING
    local button, prevButton
    local width, height = 0, 0
    local skin = ns.Addon:GetCurrentSkin()

    for i, bag in ipairs(self.meta.bags) do
        local template = ns.IsKeyring(bag) and skin.Keyring or skin.Bag
        button = ns.UI.Bag:Bind(CreateFrame('Button', nil, self, template), self.meta, bag)
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
