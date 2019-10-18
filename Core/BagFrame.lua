-- BagFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/20/2019, 3:32:48 AM

---- LUA
local ipairs = ipairs
local select = select

---@type ns
local ns = select(2, ...)

---@class tdBag2BagFrame
local BagFrame = ns.Addon:NewClass('UI.BagFrame', 'Frame')
BagFrame.SPACING = 3

---@param meta tdBag2FrameMeta
function BagFrame:Constructor(_, meta)
    local bags = meta.bags
    local spacing = self.SPACING
    local button

    for i, bag in ipairs(bags) do
        button = ns.UI.Bag:New(self, meta, bag)
        button:SetPoint('LEFT', (button:GetWidth() + spacing) * (i - 1), 0)
    end

    self:SetSize((button:GetWidth() + spacing) * #bags - spacing, button:GetHeight())
end
