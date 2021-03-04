-- .index.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/5/2020, 10:37:21 AM

---@class ns
---@field UI UI
---@field Addon Addon
---@field Events Events
---@field FrameMeta tdBag2FrameMeta
---@field Counter tdBag2Counter
---@field Forever tdBag2Forever
---@field Cache tdBag2Cache
---@field Current tdBag2Current
---@field Cacher tdBag2Cacher
---@field Thread tdBag2Thread
---@field Tooltip tdBag2Tooltip
---@field GlobalSearch tdBag2GlobalSearch

---@class tdBag2FrameProfile
---@field column number
---@field reverseBag boolean
---@field reverseSlot boolean
---@field managed boolean
---@field bagFrame boolean
---@field tokenFrame boolean
---@field pluginButtons boolean
---@field window table
---@field tradeBagOrder string
---@field iconCharacter boolean
---@field hiddenBags table<number, boolean>

---@class tdBag2Profile
---@field glowAlpha number
---@field textOffline boolean
---@field iconJunk boolean
---@field iconQuestStarter boolean
---@field glowQuest boolean
---@field glowUnusable boolean
---@field glowQuality boolean
---@field glowEquipSet boolean
---@field glowNew boolean
---@field colorSlots boolean
---@field lockFrame boolean
---@field emptyAlpha number
---@field remainLimit number
---@field style string
---@field searches string[]

---@class tdBag2WatchData
---@field itemId number
---@field watchAll boolean

---@class tdBag2CharacterProfile
---@field watches tdBag2WatchData[]
---@field hiddenBags table<number, boolean>

---@class tdBag2StyleData
---@field overrides table<string, table<string, any>>
---@field hooks table<string, table<string, function>>

---@class UI
---@field Frame tdBag2Frame
---@field SimpleFrame tdBag2SimpleFrame
---@field ContainerFrame tdBag2ContainerFrame
---@field ItemBase tdBag2ItemBase
---@field Item tdBag2Item
---@field Bag tdBag2Bag
---@field Container tdBag2Container
---@field TitleContainer tdBag2TitleContainer
---@field TitleFrame tdBag2TitleFrame
---@field OwnerSelector tdBag2OwnerSelector
---@field SearchBox tdBag2SearchBox
---@field GlobalSearchBox tdBag2GlobalSearchBox
---@field TokenFrame tdBag2TokenFrame
---@field Token tdBag2Token
---@field MenuButton tdBag2MenuButton
---@field PluginFrame tdBag2PluginFrame

---@alias tdBag2Frames table<string, tdBag2ContainerFrame>

---@class Addon
---@field private frames tdBag2Frames
---@field private styles table<string, tdBag2StyleData>
---@field private styleName string

---@class tdBag2ButtonPluginOptions
---@field type 'Button'
---@field icon number|string
---@field order number
---@field init function
---@field key string
---@field text  string

---@class tdBag2ItemPluginOptions
---@field type 'Item'
---@field init function
---@field update function
---@field text string

---@alias tdBag2PluginOptions tdBag2ButtonPluginOptions|tdBag2ItemPluginOptions

---@class tdBag2Cacher

---@class tdBag2Thread

---@class tdBag2CacheOwnerData
---@field name string
---@field realm string
---@field faction string
---@field class string
---@field race string
---@field gender number
---@field cached boolean
---@field money number

---@class tdBag2CacheBagData
---@field slot number
---@field owned boolean
---@field cached boolean
---@field count number
---@field free number
---@field family number
---@field cost number
---@field link string
---@field icon string
---@field id number
---@field title string

---@class tdBag2CacheItemData
---@field link string
---@field count number
---@field cached boolean
---@field icon string
---@field locked boolean
---@field quality number
---@field id number
---@field bound boolean
---@field readable boolean
---@field timeout number

---@class tdBag2Cache

---@class tdBag2Current

---@class tdBag2ForeverCharacter
---@field faction string
---@field class string
---@field race string
---@field gender number
---@field money number

---@alias tdBag2ForeverRealm table<string, tdBag2ForeverCharacter>
---@alias tdBag2ForeverDB table<string, tdBag2ForeverRealm>

---@class tdBag2Forever
---@field player tdBag2ForeverCharacter
---@field realm tdBag2ForeverRealm
---@field db tdBag2ForeverDB
---@field owners string[]

---@class tdBag2GlobalSearchBagItem
---@field title string
---@field bags string[]

---@class tdBag2GlobalSearch
---@field lastSearch string
---@field thread tdBag2Thread

---@class tdBag2AutoDisplay
---@field private frameKeys table<Frame, string>
---@field private profile table

---@class tdBag2Counter

---@class Events
---@field private bagSizes number[]

---@class tdBag2FrameClass
---@field Item tdBag2ItemBase
---@field Frame tdBag2Frame
---@field Container tdBag2Container

---@class tdBag2FrameMeta
---@field bagId number
---@field owner string
---@field bags number[]
---@field frame tdBag2Frame
---@field profile tdBag2FrameProfile
---@field sets tdBag2Profile
---@field character tdBag2CharacterProfile
---@field class tdBag2FrameClass
---@field title string
---@field icon string

---@class tdBag2Tooltip

---@class tdBag2MenuButton: Button
---@field private EnterBlocker Frame

---@class tdBag2Bag: tdBag2MenuButton
---@field private meta tdBag2FrameMeta
---@field private bag number

---@class tdBag2BagFrame
---@field protected meta tdBag2FrameMeta

---@class tdBag2GlobalSearchBox: EditBox

---@class tdBag2Item: tdBag2ItemBase
---@field private newitemglowAnim AnimationGroup
---@field private flashAnim AnimationGroup

---@class tdBag2ItemBase: Button
---@field protected meta tdBag2FrameMeta
---@field protected bag number
---@field protected slot number
---@field protected hasItem boolean
---@field protected notMatched boolean
---@field protected info tdBag2CacheItemData
---@field protected Overlay Frame
---@field protected Timeout FontString
---@field protected QuestBorder Texture
---@field protected JunkIcon Texture

---@class tdBag2MoneyFrame: Button
---@field private meta tdBag2FrameMeta

---@class tdBag2OwnerSelector: tdBag2MenuButton
---@field private meta tdBag2FrameMeta

---@class tdBag2SearchBox: EditBox
---@field private meta tdBag2FrameMeta

---@class tdBag2TitleFrame: Button
---@field private meta tdBag2FrameMeta

---@class tdBag2Token: Frame
---@field private Icon Texture
---@field private Count FontString
---@field private itemId number

---@class tdBag2TokenFrame: tdBag2MenuButton
---@field private meta tdBag2FrameMeta
---@field private buttons tdBag2Token[]

---@class tdBag2Container: Frame
---@field private meta tdBag2FrameMeta
---@field private itemButtons table<number, table<number, tdBag2Item>>
---@field private bagSizes table<number, number>
---@field private bagOrdered number[]

---@class tdBag2GlobalSearchContainer: tdBag2TitleContainer
---@field thread tdBag2Thread

---@class tdBag2TitleContainer: tdBag2Container
---@field alwaysShowTitle boolean

---@class tdBag2Bank: tdBag2ContainerFrame

---@class tdBag2ContainerFrame: tdBag2Frame
---@field protected Container tdBag2Container
---@field protected BagFrame tdBag2BagFrame
---@field protected TokenFrame tdBag2TokenFrame
---@field protected PluginFrame tdBag2PluginFrame

---@class tdBag2Frame: Frame
---@field protected meta tdBag2FrameMeta
---@field protected fixedHeight number
---@field protected portrait Texture
---@field protected TitleFrame tdBag2TitleFrame
---@field protected Container tdBag2Container

---@class tdBag2GlobalSearchFrame: tdBag2Frame
---@field protected Container tdBag2TitleContainer
---@field protected SearchBox tdBag2GlobalSearchBox

---@class tdBag2Inventory: tdBag2ContainerFrame

---@class tdBag2SimpleFrame: tdBag2Frame
---@field protected OwnerSelector tdBag2OwnerSelector
---@field protected SearchBox tdBag2SearchBox

---@class tdBag2BagToggle: tdBag2MenuButton
---@field private meta tdBag2FrameMeta

---@class tdBag2PluginFrame: Frame
---@field meta tdBag2FrameMeta
---@field menuButtons Button[]
---@field pluginButtons table<string, Button>

---@class tdBag2SearchToggle: tdBag2MenuButton
---@field private meta tdBag2FrameMeta

---@class Addon
