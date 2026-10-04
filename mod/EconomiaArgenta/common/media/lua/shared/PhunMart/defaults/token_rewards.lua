-- Retos de kills de Economia Argenta (cada jugador, una sola vez por partida).
--
-- Los retos de supervivencia, habilidades y "primero del server" viven en
-- server/EconomiaArgenta/retos.lua. Este archivo solo tiene los de kills,
-- que usan el contador de kills del motor.
--
-- Se activan con la opcion de sandbox EconomiaArgenta.RecompensasKills
-- (encendida por defecto). Los billetes (Base.Money) van directo al inventario
-- y aparece un aviso en pantalla.
--
--   kills = N       reto unico: se cobra una vez al llegar a N
--   everyKills = N  reto recurrente: se cobra cada N kills a partir de ahi
--
-- Montos en billetes (5 billetes = una caja de balas).
local vars = SandboxVars and SandboxVars.EconomiaArgenta
if not (vars and vars.RecompensasKills) then
    return {}
end

local function billetes(n)
    return {{
        item = "Base.Money",
        amount = n
    }}
end

return {
    zombieKills = {{
        kills = 50,
        rewards = billetes(3)
    }, {
        kills = 100,
        rewards = billetes(8)
    }, {
        kills = 250,
        rewards = billetes(20)
    }, {
        kills = 500,
        rewards = billetes(35)
    }, {
        kills = 1000,
        rewards = billetes(60)
    }, {
        kills = 2500,
        rewards = billetes(120)
    }, {
        everyKills = 1000,
        rewards = billetes(30)
    }}
}
