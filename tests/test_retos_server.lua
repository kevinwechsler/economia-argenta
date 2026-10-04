-- Prueba fuera del juego del lado servidor de los retos: que marque logros,
-- que "Reclamar" pague una sola vez y solo lo logrado, y que los "primero
-- del server" se paguen solos a un unico ganador.
--
-- Uso: luajit tests/test_retos_server.lua   (desde la raiz del proyecto)
local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = here .. "/.."
local media = root .. "/mod/EconomiaArgenta/common/media/lua"
package.path = media .. "/shared/?.lua;" .. media .. "/server/?.lua;" .. package.path

-- ---------------------------------------------------------------------------
-- Juego falso
-- ---------------------------------------------------------------------------
_G.isClient = function()
    return false
end
local md = {}
_G.ModData = {
    getOrCreate = function(k)
        md[k] = md[k] or {}
        return md[k]
    end
}
local handlers = {}
_G.Events = setmetatable({}, {
    __index = function(_, name)
        return {
            Add = function(fn)
                handlers[name] = handlers[name] or {}
                table.insert(handlers[name], fn)
            end
        }
    end
})
local horasMundo = 0
_G.getGameTime = function()
    return {
        getWorldAgeHours = function()
            return horasMundo
        end
    }
end
_G.instanceof = function(o, cls)
    return cls == "IsoPlayer" and o and o.esJugador
end
_G.sendServerCommand = function(p, mod, cmd, args)
    p.anuncios = p.anuncios or {}
    table.insert(p.anuncios, args)
end

-- Habilidades
_G.Perks = {
    None = {}
}
local cat = {}
local function perk(n)
    return {
        nombre = n,
        getParent = function()
            return cat
        end,
        getName = function()
            return n
        end
    }
end
Perks.Fitness = perk("Fitness")
Perks.Strength = perk("Strength")
local lista = {Perks.Fitness, Perks.Strength, perk("Carpinteria"), perk("Cocina")}
_G.PerkFactory = {
    PerkList = {
        size = function()
            return #lista
        end,
        get = function(_, i)
            return lista[i + 1]
        end
    }
}

local function jugador(nombre)
    local p = {
        esJugador = true,
        nombre = nombre,
        horas = 0,
        niveles = {
            Fitness = 5,
            Strength = 5
        },
        cobrado = 0
    }
    function p:getUsername()
        return self.nombre
    end
    function p:getHoursSurvived()
        return self.horas
    end
    function p:getPerkLevel(pk)
        return self.niveles[pk.nombre] or 0
    end
    function p:isDead()
        return false
    end
    function p:isAnimal()
        return false
    end
    return p
end

local killsPor = {}
package.loaded["PhunMart/core"] = true
package.loaded["PhunMart_Server/commands"] = {}
_G.PhunMart = {
    name = "PhunMart",
    isLocal = false,
    debugLn = function()
    end,
    utils = {},
    killRewards = {
        loaded = true,
        getPlayerData = function(_, u)
            return {
                zombieKills = killsPor[u] or 0
            }
        end
    },
    grantConfigReward = function(_, player, reward, reason, reto)
        player.cobrado = player.cobrado + reward.amount
    end
}
_G.SandboxVars = {
    EconomiaArgenta = {
        RecompensasKills = true,
        ModoPruebaRetos = false
    }
}
local online = {}
_G.getOnlinePlayers = function()
    return {
        size = function()
            return #online
        end,
        get = function(_, i)
            return online[i + 1]
        end
    }
end

local Retos = require "EconomiaArgenta/retos"

-- ---------------------------------------------------------------------------
local passed, failed = 0, 0
local function ok(label, cond, detail)
    if cond then
        passed = passed + 1
        print("  ok    " .. label)
    else
        failed = failed + 1
        print("  FAIL  " .. label .. (detail and ("  <- " .. tostring(detail)) or ""))
    end
end

local kevin = jugador("kevin")
local juan = jugador("juan")
online = {kevin, juan}

print("-- reclamar kills --")
killsPor.kevin = 30
ok("no se puede reclamar antes de tiempo", Retos.reclamar(kevin, "kills_50") == false)
ok("no cobro nada", kevin.cobrado == 0, kevin.cobrado)
killsPor.kevin = 120
Retos.revisar(kevin)
local d = Retos.datosPara(kevin)
ok("50 y 100 kills quedan logrados", d.logrados.kills_50 and d.logrados.kills_100)
ok("250 no", not d.logrados.kills_250)
ok("logrado no es cobrado (es manual)", kevin.cobrado == 0)
ok("reclamar 50 kills paga", Retos.reclamar(kevin, "kills_50") == true and kevin.cobrado == 3, kevin.cobrado)
ok("reclamar dos veces no paga de nuevo", Retos.reclamar(kevin, "kills_50") == false and kevin.cobrado == 3)
ok("reclamar 100 kills paga 8 mas", Retos.reclamar(kevin, "kills_100") == true and kevin.cobrado == 11, kevin.cobrado)
ok("una clave inventada no paga", Retos.reclamar(kevin, "kills_999999") == false and kevin.cobrado == 11)

print("-- primero del server --")
killsPor.juan = 1000
antes = juan.cobrado
Retos.revisar(juan)
ok("juan gana 'primero en 1000 kills' solo, sin reclamar", juan.cobrado - antes == 80, juan.cobrado - antes)
ok("queda registrado a nombre de juan", Retos.datosPara(kevin).primeros.primero_kills_1000 == "juan")
ok("kevin recibe el anuncio", kevin.anuncios and #kevin.anuncios >= 1)

print("-- cada 1000 kills --")
killsPor.kevin = 2100
local antes = kevin.cobrado
ok("cada 1000 con 2100 kills paga 2 vueltas", Retos.reclamar(kevin, "kills_cada") and kevin.cobrado - antes == 60,
    kevin.cobrado - antes)
ok("no se cobra de nuevo", Retos.reclamar(kevin, "kills_cada") == false)

print("-- dias sin morir --")
kevin.horas = 8 * 24
Retos.revisar(kevin)
ok("7 dias logrado", Retos.datosPara(kevin).logrados.dias_7)
-- muere antes de reclamar: lo logrado queda
for _, fn in ipairs(handlers.OnCharacterDeath or {}) do
    fn(kevin)
end
kevin.horas = 0
antes = kevin.cobrado
ok("aunque muera, puede reclamar lo logrado", Retos.reclamar(kevin, "dias_7") and kevin.cobrado - antes == 15)
ok("14 dias no logrado", Retos.reclamar(kevin, "dias_14") == false)

print("-- inicio limpio --")
juan.horas = 4 * 24
horasMundo = 6 * 24
Retos.revisar(juan)
ok("juan (sin muertes) logra inicio limpio", Retos.datosPara(juan).logrados.inicio_limpio)
Retos.revisar(kevin)
ok("kevin (murio) no", not Retos.datosPara(kevin).logrados.inicio_limpio)

print("-- habilidades --")
kevin.niveles.Carpinteria = 5
Retos.revisar(kevin)
ok("una habilidad a 5 (Fuerza no cuenta)", Retos.datosPara(kevin).logrados.hab5_1)
ok("tres a 5 todavia no", not Retos.datosPara(kevin).logrados.hab5_3)

antes = kevin.cobrado
Retos.revisar(kevin) -- kevin tiene 2100 kills, pero juan llego antes
ok("kevin ya no puede ganarlo", kevin.cobrado == antes)

print("-- apagados --")
SandboxVars.EconomiaArgenta.RecompensasKills = false
ok("con retos apagados no se reclama", Retos.reclamar(juan, "inicio_limpio") == false)

print("")
print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
