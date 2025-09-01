local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animations = ReplicatedStorage.Assets.Animations

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local AnimationController = {} :: ControllerTemplate.Type

local defaultAnimationName = Animations.ObjectHolding.Name

local animationsToLoad = {
    Animations.ObjectHolding
}

local function onCharacterAdded(self, character: Model)
    self._animator = character:WaitForChild("Humanoid"):WaitForChild("Animator") :: Animator
    table.clear(self._loadedAnimations)

    for _, animation: Animation in pairs(animationsToLoad) do
        self._loadedAnimations[animation.Name] = self._animator:LoadAnimation(animation)
    end

    task.wait(1)
    self._loadedAnimations[defaultAnimationName]:Play()
end

function AnimationController:AfterPlayerLoaded(player: Player)
    local character = player.Character or player.CharacterAdded:Wait()
    onCharacterAdded(self, character)

    player.CharacterAdded:Connect(function(newCharacter: Model)
        onCharacterAdded(self, newCharacter)
    end)
end

function AnimationController.new()
    local self = setmetatable(AnimationController, {__index = ControllerTemplate})
    self._loadedAnimations = {} :: {[string]: AnimationTrack}

    return self
end

return AnimationController