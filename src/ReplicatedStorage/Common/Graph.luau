local Graph = {}
Graph.__index = Graph

function Graph.new()
    local self = setmetatable({}, Graph)
    self._connections = {}
    return self
end

function Graph:ConnectDirectional(node1, node2, data)
    if not self._connections[node1] then
        self._connections[node1] = {}
    end

    self._connections[node1][node2] = if data ~= nil then data else true
end

function Graph:Connect(node1, node2, data)
    self:ConnectDirectional(node1, node2, data)
    self:ConnectDirectional(node2, node1, data)
end

function Graph:DisconnectDirectional(node1, node2)
    if not self._connections[node1] then
        return
    end

    self._connections[node1][node2] = nil

    if not next(self._connections[node1]) then
        self._connections[node1] = nil
    end
end

function Graph:Disconnect(node1, node2)
    self:DisconnectDirectional(node1, node2)
    self:DisconnectDirectional(node2, node1)
end

function Graph:GetConnections()
    return self._connections
end

function Graph:GetEdges(node)
    return self._connections[node]
end

function Graph:GetEdge(node1, node2)
    if not self._connections[node1] then
        return nil
    end

    return self._connections[node1][node2]
end

return Graph