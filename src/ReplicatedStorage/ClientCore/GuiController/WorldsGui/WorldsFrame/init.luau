local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldsConfig = require(ReplicatedStorage.Configs.WorldsConfig)
local WorldPlate = require(script.WorldPlate)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local WorldsFrame = {} :: ControllerTemplate.Type

local function fillItems(self: ControllerTemplate.Type)
    local scrollingFrame: ScrollingFrame = self._frame:WaitForChild("ScrollingFrame")
    local plateHolder: Frame = scrollingFrame:WaitForChild("Holder")

    for i = 1, #WorldsConfig.Worlds do
        local plate = plateHolder:Clone()
        plate.Parent = scrollingFrame
        plate.LayoutOrder = i

        WorldPlate.new(plate, WorldsConfig.Worlds[i], self._controllers, self._utils)

        plate.Visible = true
        plate.Name = WorldsConfig.Worlds[i].PublicName
    end
end

function WorldsFrame:AfterPlayerLoaded()
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.WorldsGui:Disable()
    end)

    fillItems(self)

    self._controllers.WorldsController.GuiOpenZoneEntered:Subscribe(self, function()
        if not self._controllers.GuiController.WorldsGui.Gui.Enabled then
            self._controllers.GuiController.WorldsGui:Enable(true)
        end
    end)
end

function WorldsFrame.new(frame: Frame)
    local self = setmetatable(WorldsFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return WorldsFrame