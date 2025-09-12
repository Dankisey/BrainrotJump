local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local InventoryFrame = {}

function InventoryFrame:ChangeCategory(name: string)
	for _, frame: Frame in pairs(self._frame.Categories:GetChildren()) do
        frame.Visible = frame.Name == name
    end

    self._frame.TopBar.TextLabel.Text = name
end

function InventoryFrame:Initialize()
    local closeButton = self._frame.CloseButton :: GuiButton

    self._controllers.ButtonsInteractionsConnector:ConnectButton(closeButton, function()
        self._controllers.GuiController.InventoryGui:Disable()
    end)

    self._trails = require(script.Trails).new(self._frame.Categories.Trails, self._controllers, self._utils)
    self._trails:Initialize()

    self._conumables = require(script.Consumables).new(self._frame.Categories.Consumables, self._controllers, self._utils)
    self._conumables:Initialize()

    for _, button: GuiButton in pairs(self._frame.SideButtons:GetChildren()) do
        if button:IsA("GuiButton") == false then continue end

        self._controllers.ButtonsInteractionsConnector:ConnectButton(button, function()
            self:ChangeCategory(button.Name)
        end)
    end

    self:ChangeCategory("Consumables")
end

function InventoryFrame.new(frame: Frame)
	local self = setmetatable(InventoryFrame, {__index = ControllerTemplate})
    self._frame = frame

	return self
end

return InventoryFrame