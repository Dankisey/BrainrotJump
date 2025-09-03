local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local ArcBuilder = {} :: ClientTypes.ArcBuilder

local function endArc(self: ClientTypes.ArcBuilder, arcData: ClientTypes.ArcData)
	for i, arc in ipairs(self._arcs) do
		if arc == arcData then
			table.remove(self._arcs, i)

			break
		end
	end

	if arcData.OnCompleteCallback then
		arcData.OnCompleteCallback()
	end

	if arcData.MovingInstance then
        arcData.MovingInstance:Destroy()
	end
end

local function tryUpdateArc(arcData: ClientTypes.ArcData, deltaTime: number) : boolean
	if not arcData.Target then return false end

    arcData.ElapsedTime += deltaTime
	local normalizedTime = math.clamp((arcData.ElapsedTime + deltaTime) / arcData.Duration, 0, 1)

	local currentPosition: Vector3 = (1 - normalizedTime) ^ 2 * arcData.StartPosition +
        2 * (1 - normalizedTime) * normalizedTime * arcData.MidPoint +
        normalizedTime ^ 2 * arcData.Target.Position

	if arcData.MovingInstance:IsA("Model") then
		arcData.MovingInstance:PivotTo(CFrame.new(currentPosition))
	else
		arcData.MovingInstance.Position = currentPosition
	end

    return true
end

local function updateAll(self: ClientTypes.ArcBuilder, deltaTime: number)
    for _, arcData in pairs(self._endedArcs) do
        endArc(self, arcData)
    end

    table.clear(self._endedArcs)

	for _, arcData in ipairs(self._arcs) do
		if not tryUpdateArc(arcData, deltaTime) then
            table.insert(self._endedArcs, arcData)
        elseif arcData.ElapsedTime >= arcData.Duration then
            table.insert(self._endedArcs, arcData)
        end
	end
end

function ArcBuilder:AddArc(movingInstance, startPosition, endPart, duration,  arcLength, angleOffset, completeCallback)
	local midPoint = (startPosition + endPart.Position) / 2
	local verticalOffset = Vector3.new(0, arcLength, 0)
	local horizontalOffset = Vector3.new(math.cos(angleOffset), 0, math.sin(angleOffset)) * arcLength
	midPoint = midPoint + verticalOffset + horizontalOffset

	local arcData: ClientTypes.ArcData = {}
	arcData.ElapsedTime = 0
	arcData.Target = endPart
	arcData.Duration = duration
    arcData.MidPoint = midPoint
    arcData.StartPosition = startPosition
    arcData.MovingInstance = movingInstance
	arcData.OnCompleteCallback = completeCallback

	table.insert(self._arcs, arcData)
end

function ArcBuilder:Initialize()
	task.spawn(function()
		while true do
			updateAll(self, task.wait(.01))
		end
	end)
end

function ArcBuilder.new()
    local self = setmetatable(ArcBuilder, {__index = ControllerTemplate})
    self._endedArcs = {} :: {ClientTypes.ArcData}
    self._arcs = {} :: {ClientTypes.ArcData}

    return self
end

return ArcBuilder