local BulletHistory = {}
BulletHistory.__index = BulletHistory

function BulletHistory.new()
	local self = setmetatable({}, BulletHistory)
    self.History = {}
	return self
end

function BulletHistory:AddBulletPoint(bulletAmount: number)
    table.insert(self.History, 1, {
        Timestamp = os.clock(),
        BulletAmount = bulletAmount
    })
end

function BulletHistory:GetBulletsFromTimestampOffset(timeOffset: number)
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

function BulletHistory:GetBulletCountFromTimestampOffset(timeOffset: number)
    local bulletCount = #self:GetBulletsFromTimestampOffset(timeOffset)
    return bulletCount
end

return BulletHistory