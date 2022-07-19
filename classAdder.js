const fs = require('fs')

const tools = [
    "Portafab",
    "Pistol",
    "SMG",
    "AssaultRifle",
    "Minigun",
    "Shotgun",
    "SniperRifle",
    "NapalmDeployer",
    "GrenadeLauncher",
    "RocketLauncher",
    "SatchelCharge",
    "CruiseMissle",
    "Scanner",
    "LaserDrill",
    "LaserStrike",
    "OrbitalFabricator",
    "OrbitalShield",
    "HighPowerPhotonLancer",
    "ApDMR",
    "AutoFlechette",
    "HandMortar",
]

function createLuaBinder(className) {
    return [
        `local ${className} = {}`,
        `${className}.__index = ${className}`,
        ``,
        `function ${className}.new(instance)`,
        `   local self = setmetatable({}, ${className})`,
        `   self.Instance = instance`,
        `   return self`,
        `end`,
        ``,
        `function ${className}:Destroy()`,
        ``,
        `end`,
        ``,
        `return ${className}`,
    ].join('\n')
}

tools.forEach((className) => {
    const source = createLuaBinder(className)
    fs.writeFileSync(`./src/ReplicatedStorage/Client/InstanceComponents/Structures/${className}.lua`, source, 'utf-8')
})