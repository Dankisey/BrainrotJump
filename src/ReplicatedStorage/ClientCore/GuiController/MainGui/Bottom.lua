local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassRequested = ReplicatedStorage.Remotes.Monetization.GamepassRequested
local GamepassesConfig = require(ReplicatedStorage.Configs.GamepassesConfig)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local Bottom = {} :: ControllerTemplate.Type

local function changeStatus(label: TextLabel, on: boolean)
    if on then
        label.Text = "ON"
    else
        label.Text = "OFF"
    end
end

function Bottom:AfterPlayerLoaded(player: Player)
	self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.AutoCollect, function()
        if self._controllers.BrainrotController.IsJumping then return end

		if not player:GetAttribute("AutoCollect") then
            GamepassRequested:FireServer(GamepassesConfig.Attributes.AutoCollect.GamepassId)
            return
        end

        if self._controllers.BrainrotController.IsInAutoJump then
            self._controllers.BrainrotController:ToggleAutoJump()
            changeStatus(self._frame.AutoJump.Status, self._controllers.BrainrotController.IsInAutoJump)
        end

        player:SetAttribute("AutoFarm", not player:GetAttribute("AutoFarm"))
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.AutoJump, function()
        if self._controllers.BrainrotController.IsJumping then return end

        if player:GetAttribute("AutoFarm") then
            player:SetAttribute("AutoFarm", false)
        end

		self._controllers.BrainrotController:ToggleAutoJump()
        changeStatus(self._frame.AutoJump.Status, self._controllers.BrainrotController.IsInAutoJump)
    end)

    player.AttributeChanged:Connect(function(attribute)
		if attribute == "AutoCollect" then
            player:SetAttribute("AutoFarm", true)
        end

	    if attribute == "AutoFarm" then
			local autoFarm = player:GetAttribute("AutoFarm")
            changeStatus(self._frame.AutoCollect.Status, autoFarm)
	    end
    end)
end

function Bottom.new(frame: Frame)
    local self = setmetatable(Bottom, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return Bottom