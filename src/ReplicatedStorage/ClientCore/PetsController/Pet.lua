local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)

local Pet = {}

export type PetClass = {
    ShowHappinessPrompt: () -> ();
    Destroy: (PetClass) -> ();
    new: (PetsConfig.PetData, Part, boolean) -> PetClass;
}

local circle = math.pi * .75

local function getPosition2(angle, radius, grid, index, amountofpets, petsize)
	if grid == math.round(grid) then
		return ((index % grid) * 4.5) - (grid - 1) * 2, (math.ceil(index / (amountofpets /(amountofpets / grid)))) * 4.5 + PetsConfig.ServiceData.DefaultDistanceFromPlayer
	end
end

function Pet:PositionPet(i, character, pet, folder)
		local radius = 3 + #folder:GetChildren()
		local angle = i * (circle / #folder:GetChildren())
		local _, petSize = pet:GetBoundingBox()
		local x, z = getPosition2(angle, radius, 3, i, #folder:GetChildren())
		local _, characterSize = character:GetBoundingBox()
		local offsetYInstance = pet:FindFirstChild("OffsetY")
		local offsetY = offsetYInstance and offsetYInstance.Value or 0
		local sin = (math.sin(15 * time() + 1.6) / .5) + 1
		local cos = math.cos(7 * time() + 1) / 4
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {pet:GetChildren(), character:GetDescendants()}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		if not character.PrimaryPart then
			return
		end

		local raycast = workspace:Raycast(pet.PrimaryPart.Position + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), raycastParams)
		local new_cframe

		if raycast then
		    new_cframe = CFrame.new(Vector3.new(character.PrimaryPart.Position.X,raycast.Position.Y + 1,character.PrimaryPart.Position.Z))
			new_cframe = new_cframe * CFrame.fromEulerAnglesXYZ(character.PrimaryPart.CFrame:toEulerAnglesXYZ())
		else
			new_cframe = CFrame.new(Vector3.new(character.PrimaryPart.Position.X,character.PrimaryPart.Position.Y - 3,character.PrimaryPart.Position.Z))
			new_cframe = new_cframe * CFrame.fromEulerAnglesXYZ(character.PrimaryPart.CFrame:toEulerAnglesXYZ())
		end

		local magnitude = (character.PrimaryPart.Position - pet.PrimaryPart.Position).Magnitude

		if magnitude > PetsConfig.ServiceData.MaxDistanceFromPlayer then
			new_cframe = character.PrimaryPart.CFrame
		end

		if character.Humanoid.MoveDirection.Magnitude > 0  then
			if pet:FindFirstChild("Walks") then
				pet:SetPrimaryPartCFrame(pet.PrimaryPart.CFrame:Lerp(new_cframe * CFrame.new(x, offsetY + sin, z) * CFrame.fromEulerAnglesXYZ(cos, 0, 0), PetsConfig.ServiceData.LerpTime))
			else
				pet:SetPrimaryPartCFrame(pet.PrimaryPart.CFrame:Lerp(new_cframe * CFrame.new(x, offsetY / 2 + math.sin(time() * 3) + 1, z), PetsConfig.ServiceData.LerpTime))
			end
		else
			if pet:FindFirstChild("Walks") then 
				pet:SetPrimaryPartCFrame(pet.PrimaryPart.CFrame:Lerp(new_cframe * CFrame.new(x, offsetY, z), 0.1))
			else
				pet:SetPrimaryPartCFrame(pet.PrimaryPart.CFrame:Lerp(new_cframe * CFrame.new(x, offsetY / 2 + math.sin(time() * 3) + 1, z), PetsConfig.ServiceData.LerpTime))
			end
		end
end

local function initialize(self, petData: PetsConfig.PetData, key: string, player: Player, owner: Player, petsFolder: Folder)
    self._model = PetsConfig.Pets[petData.ConfigName].Model:Clone()
	self._folder = petsFolder

    self._model:SetAttribute("Key", key)
	local ownerUserId = owner.UserId
    self._model.Parent = petsFolder[ownerUserId]
    self._petData = petData
    self._key = key
    self._owner = owner

    self._player = player
    self._isGolden = false
end

function Pet:Destroy()
    self._model:Destroy()
end

function Pet.new(...) : PetClass
    local self = setmetatable({}, {__index = Pet})

	task.spawn(initialize, self, ...)

    return self
end

return Pet