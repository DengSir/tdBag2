---@class __tdBag2BaseFrameTemplate_TitleFrame : Button
---@field Text FontString
local __tdBag2BaseFrameTemplate_TitleFrame = {}

---@class __tdBag2BaseFrameTemplate_Inset : InsetFrameTemplate , Frame

---@class __tdBag2BaseFrameTemplate_SearchBox : SearchBoxTemplate , EditBox

---@class tdBag2BaseFrameTemplate : PortraitFrameTemplate , Frame
---@field CircleMask MaskTexture
---@field TitleFrame __tdBag2BaseFrameTemplate_TitleFrame
---@field OwnerSelector Button
---@field Inset __tdBag2BaseFrameTemplate_Inset
---@field Container Frame
---@field SearchBox __tdBag2BaseFrameTemplate_SearchBox
---@field fixedWidth number
---@field fixedHeight number
local tdBag2BaseFrameTemplate = {}

---@class __tdBag2FrameTemplate_MoneyFrame : Button
---@field BgLeft Texture
---@field BgRight Texture
---@field BgMiddle Texture
local __tdBag2FrameTemplate_MoneyFrame = {}

---@class __tdBag2FrameTemplate_TokenFrame : Button
---@field BgLeft Texture
---@field BgRight Texture
---@field BgMiddle Texture
local __tdBag2FrameTemplate_TokenFrame = {}

---@class tdBag2FrameTemplate : tdBag2BaseFrameTemplate , Frame
---@field BtnCornerLeft Texture
---@field BtnCornerRight Texture
---@field ButtonBottomBorder Texture
---@field BagFrame Frame
---@field PluginFrame Frame
---@field MoneyFrame __tdBag2FrameTemplate_MoneyFrame
---@field TokenFrame __tdBag2FrameTemplate_TokenFrame
---@field fixedWidth number
---@field fixedHeight number
local tdBag2FrameTemplate = {}

---@class tdBag2TokenTemplate : Frame
---@field Icon Texture
---@field Count FontString
local tdBag2TokenTemplate = {}

---@class tdBag2BaseBagTemplate : Button
local tdBag2BaseBagTemplate = {}

---@class tdBag2BagTemplate : tdBag2BaseBagTemplate , Button
---@field Icon Texture
---@field Count FontString
local tdBag2BagTemplate = {}

---@class tdBag2KeyringTemplate : tdBag2BaseBagTemplate , Button
local tdBag2KeyringTemplate = {}

---@class tdBag2ToggleButtonTemplate : CheckButton
---@field bg Texture
---@field texture Texture
---@field CircleMask MaskTexture
local tdBag2ToggleButtonTemplate = {}

---@class tdBag2ContainerTitleTemplate : Frame
---@field Text FontString
local tdBag2ContainerTitleTemplate = {}

---@class __tdBag2ScrollFrameTemplate_ScrollBar : UIPanelStretchableArtScrollBarTemplate , Slider

---@class tdBag2ScrollFrameTemplate : UIPanelScrollFrameCodeTemplate , ScrollFrame
---@field ScrollBar __tdBag2ScrollFrameTemplate_ScrollBar
local tdBag2ScrollFrameTemplate = {}

---@class tdBag2SearchingTemplate : Frame
local tdBag2SearchingTemplate = {}
