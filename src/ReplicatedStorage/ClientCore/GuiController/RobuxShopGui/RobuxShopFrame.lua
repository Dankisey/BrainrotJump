local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local GamepassesConfig = require(ReplicatedStorage.Configs.GamepassesConfig)
local DevProductsConfig = require(ReplicatedStorage.Configs.DevProductsConfig)
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local CurrenciesPacksConfig = require(ReplicatedStorage.Configs.CurrenciesPacksConfig)
local ConsumablesConfig = require(ReplicatedStorage.Configs.ConsumablesConfig)

local Remotes = ReplicatedStorage.Remotes.Monetization
local DevProductRequested = Remotes.DevProductRequested
local GamepassRequested = Remotes.GamepassRequested
local GamepassPurchased = Remotes.GamepassPurchased
local StarterPackPurchased = Remotes.StarterPackPurchased

local WorldUnlocked = ReplicatedStorage.Remotes.Worlds.WorldUnlocked

local RobuxShopFrame = {}

local robuxSign = ""

local function getPlayersHighestOpenWorld(self)
    for i = #self._configs.WorldsConfig.Worlds, 1, -1 do
        local unlocked = self._controllers.WorldsController:IsWorldUnlocked(i)

        if unlocked then
            self.HighestOpenWorld = i
            break
        end
    end
end

local function setupCurrencyPacks(self, currencyName)
    local currencyFrame = self._scrollingFrame.Currencies:FindFirstChild(currencyName)

    for _, frame in currencyFrame:GetChildren() do
        if not frame:IsA("Frame") then continue end

        local frameName = frame.Name
        local buyButton = frame.BuyButton
        local devProductInfo = self._utils.TryGetProductInfo(DevProductsConfig[currencyName][frameName], Enum.InfoType.Product)
        frame.Title.Text = "x $" .. self._utils.FormatNumber(CurrenciesPacksConfig[currencyName][self.HighestOpenWorld][frameName])
        buyButton.Label.Text = robuxSign .. " " .. devProductInfo.PriceInRobux

        self._controllers.ButtonsInteractionsConnector:ConnectButton(buyButton, function()
            DevProductRequested:FireServer(DevProductsConfig[currencyName][frameName])
        end)
    end
end

local function updateCurrencyPacks(self, currencyName)
    local currencyFrame = self._scrollingFrame.Currencies:FindFirstChild(currencyName)

    for _, frame in currencyFrame:GetChildren() do
        if not frame:IsA("Frame") then continue end

        frame.Title.Text = "x $" .. self._utils.FormatNumber(CurrenciesPacksConfig[currencyName][self.HighestOpenWorld][frame.Name])
    end
end

function RobuxShopFrame:GoToSection(sectionName: string)
    local sectionAbsolutePosition = self._sections[sectionName]

    if not sectionAbsolutePosition then
        return warn("Section with name", sectionName, "was not found")
    end

    local sectionCanvasPosition = sectionAbsolutePosition - self._startPosition
    self._scrollingFrame.CanvasPosition = Vector2.new(0, sectionCanvasPosition)
end

function RobuxShopFrame:AfterPlayerLoaded(player: Player)
    for pass, info in GamepassesConfig.Attributes do
        local ownsGamePass = player:GetAttribute(info.AttributeName) or false
        local passFrame = self._scrollingFrame.Passes:FindFirstChild(pass)
        passFrame.OwnedFrame.Visible = ownsGamePass
        passFrame.BuyButton.Visible = not ownsGamePass
    end

    if player:GetAttribute("StarterPackPurchased") then
        self._scrollingFrame.StarterPack.Visible = false
        self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._scrollingFrame.StarterPack.BuyButton)
    end

    -- currencies

    self._sections.Currencies = self._scrollingFrame.Currencies.CategoryLabel.AbsolutePosition.Y

    getPlayersHighestOpenWorld(self)

    if not self.HighestOpenWorld then
        local tries = 0

        while tries < 5 do
            task.wait(2)
            getPlayersHighestOpenWorld(self)

            if self.HighestOpenWorld then break end

            tries += 1
        end
    end

    setupCurrencyPacks(self, "Cash")
    setupCurrencyPacks(self, "Wins")

    WorldUnlocked.OnClientEvent:Connect(function(worldIndex: number)
        self.HighestOpenWorld = worldIndex
        updateCurrencyPacks(self, "Cash")
        updateCurrencyPacks(self, "Wins")
    end)
end

function RobuxShopFrame:Initialize()
    self._closeButton = self._frame.CloseButton

	local function closeShop()
		self._controllers.GuiController.RobuxShopGui:Disable()
	end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._closeButton, closeShop)

    self._scrollingFrame = self._frame.ScrollingFrame :: ScrollingFrame
    self._startPosition = self._scrollingFrame.AbsolutePosition.Y
    self._scrollingFrame.CanvasPosition = Vector2.zero
    self._sections = {}

    -- starter pack

    local starterPackFrame = self._scrollingFrame.StarterPack

    local buyButton = starterPackFrame.BuyButton
    local devProductInfo = self._utils.TryGetProductInfo(DevProductsConfig.Others.StarterPack, Enum.InfoType.Product)
    buyButton.Label.Text = robuxSign .. " " .. devProductInfo.PriceInRobux

    self._controllers.ButtonsInteractionsConnector:ConnectButton(starterPackFrame.BuyButton, function()
        DevProductRequested:FireServer(DevProductsConfig.Others.StarterPack)
    end)

    -- eggs

    local eggFrames = self._scrollingFrame.Eggs

    for _, eggFrame in eggFrames:GetChildren() do
        if not eggFrame:IsA('Frame') then continue end
        local eggName = eggFrame.Name

        local eggProductInfo = self._utils.TryGetProductInfo(DevProductsConfig.Eggs[eggName], Enum.InfoType.Product)
        eggFrame:FindFirstChild("1").PriceLabel.Text = eggProductInfo.PriceInRobux

        self._controllers.ButtonsInteractionsConnector:ConnectButton(eggFrame:FindFirstChild("1"), function()
            DevProductRequested:FireServer(DevProductsConfig.Eggs[eggName])
            self._controllers.GuiController.RobuxShopGui:Disable()
        end)

        local tripleEggProductInfo = self._utils.TryGetProductInfo(DevProductsConfig.TripleEggs[eggName], Enum.InfoType.Product)
        eggFrame:FindFirstChild("3").PriceLabel.Text = tripleEggProductInfo.PriceInRobux

        self._controllers.ButtonsInteractionsConnector:ConnectButton(eggFrame:FindFirstChild("3"), function()
            DevProductRequested:FireServer(DevProductsConfig.TripleEggs[eggName])
            self._controllers.GuiController.RobuxShopGui:Disable()
        end)

        local drops = eggFrame.Drops

        for petName, petChance in EggConfig[eggName].Pets do
            local frame = drops.Template:Clone()
            frame.Btn.Chance.Text = petChance * 100 .. "%"
            frame.Btn.Multiplier.Text = "x" .. PetsConfig.Pets[petName].WinsMultiplier
            frame.Parent = drops
            frame.Visible = true
			frame.LayoutOrder = - petChance * 100
			frame.Btn.RewardIcon.Image = PetsConfig.Pets[petName].Icon
            self._controllers.TooltipsController:RegisterPetTooltip(frame, petName, false, false)
        end
    end

    -- passes

    local passesFrame = self._scrollingFrame.Passes

    for _, passFrame in passesFrame:GetChildren() do
        if not passFrame:IsA("Frame") then continue end

        task.spawn(function()
            local passName = passFrame.Name

            local passButton = passFrame.BuyButton
            local passInfo = self._utils.TryGetProductInfo(GamepassesConfig.Attributes[passName].GamepassId, Enum.InfoType.GamePass)
            passButton.Label.Text = robuxSign .. " " .. passInfo.PriceInRobux

            self._controllers.ButtonsInteractionsConnector:ConnectButton(passButton, function()
                GamepassRequested:FireServer(GamepassesConfig.Attributes[passName].GamepassId)
            end)
        end)
    end

    --self._sections.Passes = self._scrollingFrame.Passes.CategoryLabel.AbsolutePosition.Y

    -- potions
    local potionsFrame = self._scrollingFrame.Potions.MainFrame

    for _, frame in potionsFrame:GetChildren() do
        if not frame:IsA("Frame") then continue end

        task.spawn(function()
            local potionName = frame.Name
            local button = frame.Button
            button.NameLabel.Text = ConsumablesConfig.UiInfo[potionName].PublicName
            local productInfo = self._utils.TryGetProductInfo(DevProductsConfig.Potions[potionName], Enum.InfoType.Product)
            button.PriceLabel.Text = robuxSign .. productInfo.PriceInRobux

            self._controllers.ButtonsInteractionsConnector:ConnectButton(button, function()

                DevProductRequested:FireServer(DevProductsConfig.Potions[potionName])
            end)

            self._controllers.TooltipsController:RegisterTooltip(button, ConsumablesConfig.UiInfo[potionName].TooltipInfo)
        end)
    end

    GamepassPurchased.OnClientEvent:Connect(function(attributeName)
        for pass, info in GamepassesConfig.Attributes do
            if info.AttributeName ~= attributeName then continue end

            local passFrame = self._scrollingFrame.Passes:FindFirstChild(pass)
            passFrame.OwnedFrame.Visible = true
            passFrame.BuyButton.Visible = false
        end
    end)

    StarterPackPurchased.OnClientEvent:Connect(function()
        starterPackFrame.Visible = false
        self._controllers.ButtonsInteractionsConnector:DisconnectButton(starterPackFrame.BuyButton)
    end)
end

function RobuxShopFrame.new(frame: Frame)
    local self = setmetatable(RobuxShopFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return RobuxShopFrame