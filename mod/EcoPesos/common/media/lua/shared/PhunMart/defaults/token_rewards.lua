-- Recompensas por hitos de kills (opcional, apagado por defecto).
--
-- Se activa con la opcion de sandbox EcoPesos.RecompensasKills. Paga billetes
-- (Base.Money) directamente al inventario del jugador. El conteo de kills vive
-- dentro del sistema de tokens del motor, asi que ademas hace falta
-- PhunMart.EnableTokenPool = true (los tokens en si no se usan en ninguna
-- tienda de Eco Pesos).
--
-- Un admin puede reemplazar esta tabla con PhunMart_TokenRewards.json en la
-- carpeta Lua del server (se carga completa, no se mezcla).
local vars = SandboxVars and SandboxVars.EcoPesos
if not (vars and vars.RecompensasKills) then
    return {}
end

local function pesos(n)
    return {{
        item = "Base.Money",
        amount = n
    }}
end

return {
    zombieKills = {{
        kills = 50,
        rewards = pesos(20)
    }, {
        kills = 200,
        rewards = pesos(50)
    }, {
        kills = 500,
        rewards = pesos(100)
    }, {
        kills = 1000,
        rewards = pesos(200)
    }, {
        everyKills = 500,
        rewards = pesos(50)
    }},

    sprinterKills = {{
        kills = 25,
        rewards = pesos(30)
    }}
}
