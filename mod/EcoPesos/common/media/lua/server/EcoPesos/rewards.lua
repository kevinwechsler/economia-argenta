-- Recompensas por kills (opcional, apagado por defecto).
--
-- PhunMart carga su config de milestones en Core:ini y luego dispara
-- OnPhunMartOnReady. Si la opcion EcoPesos.RecompensasKills esta activa,
-- reemplazamos esa config por una que paga billetes (Base.Money).
--
-- Requisito de PhunMart: EnableTokenPool = true, porque el conteo de kills
-- vive dentro del sistema de tokens. Los tokens en si no se usan en ninguna
-- tienda de Eco Pesos, asi que no afectan la economia.
if isClient() then
    return
end

require "PhunMart/core"
require "EcoPesos/init"

local Core = PhunMart

local function pesos(n)
    return {{
        item = "Base.Money",
        amount = n
    }}
end

local function aplicarRecompensas()
    if not EcoPesos.getOption("RecompensasKills", false) then
        return
    end
    Core.tokenRewardsCfg = {
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
end

Events[Core.events.OnReady].Add(aplicarRecompensas)
