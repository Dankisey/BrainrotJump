
local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
local PromptsGui = PlayerGui:WaitForChild("CustomPrompts")
local UserInputService = game:GetService("UserInputService")

local EggPromptTemplate = {}

local function temporarilyDisable(self, prompt)
	self._guiPerPrompt[prompt].Enabled = false
	task.wait(4)

	if not self._customPromptsController.CustomPrompts["EggPrompt"][prompt].PlayerInRange then return end

	self._guiPerPrompt[prompt].Enabled = true
end

function EggPromptTemplate:Enable(prompt: ProximityPrompt)
	local part = prompt.Parent or prompt.AncestryChanged:Wait()
	self._guiPerPrompt[prompt] = self._gui:Clone()
	self._guiPerPrompt[prompt].Parent = PromptsGui
	self._guiPerPrompt[prompt].Adornee = part

    if self.OnEnabled then
        self:OnEnabled(prompt, self._guiPerPrompt[prompt])
    end

	task.spawn(function()
		local frame = self._guiPerPrompt[prompt]:WaitForChild("EggFrame", 1)

		if not frame then return end

		local buttons = frame:WaitForChild("Buttons", 1)

		if not buttons then return end

		self._buttonsInteractionsConnector:ConnectButton(buttons.OpenOne.TextButton, self.Hatch, self, prompt)

        self._buttonsInteractionsConnector:ConnectButton(buttons.Open3.TextButton, self.Triple, self, prompt)

        self._buttonsInteractionsConnector:ConnectButton(buttons.Auto.TextButton, self.AutoHatch, self, prompt)

        local top = frame:WaitForChild("Top", 1)

        if not top then return end

        local luckButtons = top:WaitForChild("Luck", 1)

        if not luckButtons then return end

        self._buttonsInteractionsConnector:ConnectButton(luckButtons.Luck.TextButton, self.Luck, self, prompt)

        self._buttonsInteractionsConnector:ConnectButton(luckButtons.MegaLuck.TextButton, self.MegaLuck, self, prompt)

        self._buttonsInteractionsConnector:ConnectButton(luckButtons.UltraLuck.TextButton, self.UltraLuck, self, prompt)
	end)

	self._inputConnections[prompt] = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonX then
			self:Use(prompt)
		end

		if input.KeyCode == Enum.KeyCode.T then
			self:AutoHatch(prompt)
		end
	end)

	self._guiPerPrompt[prompt].Enabled = true
end

function EggPromptTemplate:Disable(prompt: ProximityPrompt)
	if self._guiPerPrompt[prompt] then
		self._guiPerPrompt[prompt]:Destroy()
	end

	if self._inputConnections[prompt] then
		self._inputConnections[prompt]:Disconnect()
		self._inputConnections[prompt] = nil
	end

	if self.OnDisabled then
    	self:OnDisabled(prompt)
    end
end

function EggPromptTemplate:Hatch(prompt: ProximityPrompt)
    self:OnHatchClicked(prompt)

	task.spawn(function()
		temporarilyDisable(self, prompt)
	end)
end

function EggPromptTemplate:AutoHatch(prompt: ProximityPrompt)
    self:OnAutoHatchClicked(prompt)
	self:Disable(prompt)
end

function EggPromptTemplate:Triple(prompt: ProximityPrompt)
    self:OnTripleClicked(prompt)

	task.spawn(function()
		temporarilyDisable(self, prompt)
	end)
end

function EggPromptTemplate:Luck(prompt: ProximityPrompt)
    self:OnLuckClicked(prompt)
end

function EggPromptTemplate:MegaLuck(prompt: ProximityPrompt)
    self:OnMegaLuckClicked(prompt)
end

function EggPromptTemplate:UltraLuck(prompt: ProximityPrompt)
    self:OnUltraLuckClicked(prompt)
end

function EggPromptTemplate:Use(prompt: ProximityPrompt)
    self:OnUsed(prompt)

	task.spawn(function()
		temporarilyDisable(self, prompt)
	end)
end

return EggPromptTemplate