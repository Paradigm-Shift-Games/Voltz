local BulletHistory = {}
BulletHistory.__index = BulletHistory

type BulletData = {
    Timestamp: number,
    BulletAmount: number
}

function BulletHistory.new()
	local self = setmetatable({}, BulletHistory)
    self.History = {}
    self.MaxBulletAge = 5
	return self
end

function BulletHistory:AddBulletPoint(bulletAmount: number)
    local bulletData: BulletData = {
        Timestamp = os.clock(),
        BulletAmount = bulletAmount
    }
    table.insert(self.History, 1, bulletData)
    self:Cleanup()
end

function BulletHistory:GetBulletsFromTimestampOffset(timeOffset: number): Array<BulletData>
    local bullets = {}
    local timestamp = os.clock()-timeOffset

    for _, bulletData in self.History do
        if bulletData.Timestamp < timestamp then
            break
        end
        table.insert(bullets, bulletData)
    end

    return bullets
end

function BulletHistory:GetBulletCountFromTimestampOffset(timeOffset: number): number
    local bulletCount = #self:GetBulletsFromTimestampOffset(timeOffset)
    return bulletCount
end

function BulletHistory:Cleanup()
    local minAge = os.clock()-5
    for i = #self.History, 1, -1 do
        local bulletHistory = self.History[i]
        if minAge > bulletHistory.Timestamp then
            table.remove(self.History, i)
        else
            break
        end
    end
end

return BulletHistory