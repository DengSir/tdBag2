-- Bank.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/17/2019, 6:42:42 PM

---- LUA
local select = select

---- WOW
local CloseBankFrame = CloseBankFrame

---@type ns
local ns = select(2, ...)
local Frame = ns.UI.Frame

---@class tdBag2Bank: tdBag2Frame
local Bank = ns.Addon:NewClass('UI.Bank', Frame)

function Bank:OnHide()
    CloseBankFrame()
    Frame.OnHide(self)
end
