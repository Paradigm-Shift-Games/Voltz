local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Queue = require(ReplicatedStorage.Common.Queue)

local GraphUtil = {}

function GraphUtil.GetConnections(graph, node)
    -- Create queue and visited table
    local queue = Queue.new()
    local visited = {}

    -- Queue starter node and mark as visited
    visited[node] = true
    queue:PushEnd(node)

    while queue:Size() > 0 do
        -- Get next node
        local current = queue:PopStart()

        for other, _ in graph:GetNodeConnections(current) do
            -- Handle unvisited nodes
            if not visited[node] then
                queue:PushEnd(other)
                visited[other] = true
            end
        end
    end

    return visited
end

function GraphUtil.IsConnected(graph, node, target)
    -- Create queue and visited table
    local queue = Queue.new()
    local visited = {}

    -- Queue starter node and mark as visited
    visited[node] = true
    queue:PushEnd(node)

    while queue:Size() > 0 do
        -- Get next node
        local current = queue:PopStart()

        -- Search for target
        if current == target then
            return true
        end

        for other, _ in graph:GetNodeConnections(current) do
            -- Handle unvisited nodes
            if not visited[node] then
                queue:PushEnd(other)
                visited[other] = true
            end
        end
    end

    return false
end

return GraphUtil