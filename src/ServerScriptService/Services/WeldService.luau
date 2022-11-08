local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Graph = require(ReplicatedStorage.Common.Graph)
local Knit = require(ReplicatedStorage.Packages.Knit)

local WeldService = Knit.CreateService {
    Name = "WeldService";
    Client = {};
}

function WeldService:_createWeld(part1, part2, parent)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part1
    weld.Part1 = part2
    weld.Parent = parent

    return weld
end

function WeldService:WeldModel(model)
    local primaryPart = assert(model.PrimaryPart, "Model has no primary part!")

    for _, v in model:GetChildren() do
        if v == model.PrimaryPart then
            continue
        end

        self:_createWeld(primaryPart, v, model)
    end
end

function WeldService:RemoveModel(model)
    for otherModel, weld in self._weldGraph:GetEdges(model) do
        weld:Destroy()
        self._weldGraph:Disconnect(model, otherModel)
    end

    if self._connections[model] then
        self._connections[model]:Disconnect()
        self._connections[model] = nil
    end
end

function WeldService:WeldModels(model1, model2)
    assert(model1.PrimaryPart, "Model has no primary part!")
    assert(model2.PrimaryPart, "Model has no primary part!")

    if self._weldGraph:IsNeighbor(model1, model2) then
        return
    end

    if not self._connections[model1] then
        self._connections[model1] = model1.Destroying:Connect(function() self:RemoveModel(model1) end)
    end

    if not self._connections[model2] then
        self._connections[model2] = model2.Destroying:Connect(function() self:RemoveModel(model2) end)
    end

    local weld = self:_createWeld(model1.PrimaryPart, model2.PrimaryPart, self._weldFolder)
    self._weldGraph:Connect(model1, model2, weld)
end

function WeldService:KnitInit()
    self._weldFolder = Instance.new("Folder")
    self._weldFolder.Name = "WeldFolder"
    self._weldFolder.Parent = workspace
    self._weldGraph = Graph.new()
    self._connections = {}
end

return WeldService