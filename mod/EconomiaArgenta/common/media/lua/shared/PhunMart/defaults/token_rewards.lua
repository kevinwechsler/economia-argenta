-- Retos de kills de Economia Argenta, en el formato del motor.
--
-- Los numeros salen de shared/EconomiaArgenta/retos_def.lua (unico lugar de
-- objetivos y premios). Cada jugador cobra cada reto una sola vez por
-- partida; el recurrente se cobra cada N kills despues.
--
-- Se activan con la opcion de sandbox EconomiaArgenta.RecompensasKills.
local Def = require "EconomiaArgenta/retos_def"

if not Def.activos() then
    return {}
end

local function billetes(n)
    return {{
        item = "Base.Money",
        amount = n
    }}
end

local r = Def.actuales()
local zombieKills = {}
for _, k in ipairs(r.kills) do
    table.insert(zombieKills, {
        kills = k.kills,
        rewards = billetes(k.pago)
    })
end
table.insert(zombieKills, {
    everyKills = r.killsCada.kills,
    rewards = billetes(r.killsCada.pago)
})

return {
    zombieKills = zombieKills
}
