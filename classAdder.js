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

function loadClasses(directory, classNames) {
    classNames.forEach((className) => {
        const source = createLuaBinder(className)
        fs.writeFileSync(`${directory}/${className}.lua`, source, 'utf-8')
    })
}

loadClasses('./src/ReplicatedStorage/Client/InstanceComponents/Tools', tools)
loadClasses('./src/ServerScriptService/InstanceComponents/Tools', tools)