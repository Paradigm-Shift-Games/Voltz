local TerrainConfig = {
    Island = {
        MainlandSize = 45,
        StarterIslandDistance = 15,
        
        Grass = {
            Scale = 16,
            Weight = 0.5,
        },

        Gaps = {
            Scale = 16,
            Weight = 0.19,
        },

        Depth = {
            Scale = 32,
            Magnitude = 2,
        },
    },

    Crystal = {
        CrystalSpawnRate = 0.05,
    },

    Beacon = {
        BeaconCount = 7,
    },

    Support = {
        SupportSpacing = 7,
        SupportHeight = 10,
    },

    Spire = {
        Cities = {
            Scale = 32,
            Weight = 0.5,
        },

        Buildings = {
            Scale = 12,
            Weight = 0.5,
        },

        Alleys = {
            Scale = 3,
            Weight = 0.5,
        },

        Height = {
            Scale = 8,
            Magnitude = 16,
        }
    },
}

return TerrainConfig