---@meta
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

---@class tdBag2EquipBagToggleFrameTemplate : Button
---@field ring Texture
---@field icon Texture
local tdBag2EquipBagToggleFrameTemplate = {}

---@class __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle1 : tdBag2EquipBagToggleFrameTemplate , Button

---@class __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle2 : tdBag2EquipBagToggleFrameTemplate , Button

---@class __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle3 : tdBag2EquipBagToggleFrameTemplate , Button

---@class __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle4 : tdBag2EquipBagToggleFrameTemplate , Button

---@class __tdBag2EquipContainerCenterFrameBaseTemplate_Model : ModelWithControlsTemplate , PlayerModel

---@class __tdBag2EquipContainerCenterFrameBaseTemplate_NoModel : Frame
---@field Faction Texture
---@field Class Texture
local __tdBag2EquipContainerCenterFrameBaseTemplate_NoModel = {}

---@class tdBag2EquipContainerCenterFrameBaseTemplate : Frame
---@field Toggle1 __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle1
---@field Toggle2 __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle2
---@field Toggle3 __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle3
---@field Toggle4 __tdBag2EquipContainerCenterFrameBaseTemplate_Toggle4
---@field Model __tdBag2EquipContainerCenterFrameBaseTemplate_Model
---@field NoModel __tdBag2EquipContainerCenterFrameBaseTemplate_NoModel
local tdBag2EquipContainerCenterFrameBaseTemplate = {}

---@class tdBag2EquipContainerCenterFrameTemplate : tdBag2EquipContainerCenterFrameBaseTemplate , Frame
---@field BackgroundTopLeft Texture
---@field BackgroundTopRight Texture
---@field BackgroundBotLeft Texture
---@field BackgroundBotRight Texture
---@field BackgroundOverlay Texture
---@field BorderTopLeft Texture
---@field BorderTopRight Texture
---@field BorderBottomLeft Texture
---@field BorderBottomRight Texture
---@field BorderLeft Texture
---@field BorderRight Texture
---@field BorderTop Texture
---@field BorderBottom Texture
---@field BorderBottom2 Texture
local tdBag2EquipContainerCenterFrameTemplate = {}
