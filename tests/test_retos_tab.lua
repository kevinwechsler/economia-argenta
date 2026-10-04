-- Prueba fuera del juego de la pestana Retos: arma las filas con un
-- personaje y datos falsos y revisa que salgan bien. No dibuja nada.
--
-- Uso: luajit tests/test_retos_tab.lua   (desde la raiz del proyecto)
local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = here .. "/.."
local media = root .. "/mod/EconomiaArgenta/common/media/lua"
package.path = media .. "/shared/?.lua;" .. media .. "/client/?.lua;" .. package.path

-- ---------------------------------------------------------------------------
-- Juego falso, lo minimo para cargar el archivo
-- ---------------------------------------------------------------------------
local textos = {}
_G.getText = function(k, ...)
    local args = {...}
    textos[k] = true
    return k .. (#args > 0 and ("[" .. table.concat(args, "|") .. "]") or "")
end
_G.isServer = function()
    return false
end
_G.getTextManager = function()
    return {
        getFontHeight = function()
            return 14
        end,
        MeasureStringX = function(_, _, s)
            return #s * 6
        end
    }
end
_G.UIFont = {
    Small = 1,
    Medium = 2
}
_G.Keyboard = {
    KEY_0 = 11
}
local function evento()
    return {
        Add = function()
        end
    }
end
_G.Events = setmetatable({}, {
    __index = function()
        return evento()
    end
})
_G.ISPanel = {
    derive = function(_, name)
        return {
            Type = name
        }
    end
}
_G.ISCharacterInfoWindow = {
    createChildren = function()
    end,
    onTabTornOff = function()
    end
}
package.loaded["ISUI/ISPanel"] = true
package.loaded["PhunMart/core"] = true
package.loaded["PhunMart_Client/commands"] = {}
_G.PhunMart = {
    name = "PhunMart",
    isLocal = true,
    utils = {
        formatWholeNumber = function(n)
            return tostring(n)
        end
    }
}
_G.SandboxVars = {
    EconomiaArgenta = {
        RecompensasKills = true,
        ModoPruebaRetos = false
    }
}

-- Habilidades falsas: Carpinteria 6, Cocina 5, Aim 2, Fuerza 5 (no cuenta).
local function perk(nombre, parent)
    return {
        nombre = nombre,
        getParent = function()
            return parent
        end,
        getName = function()
            return nombre
        end
    }
end
_G.Perks = {
    None = {
        none = true
    }
}
local cat = {}
Perks.Fitness = perk("Fitness", cat)
Perks.Strength = perk("Strength", cat)
local lista = {Perks.Fitness, Perks.Strength, perk("Carpinteria", cat), perk("Cocina", cat), perk("Punteria", cat),
               perk("Categoria", Perks.None)}
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
local niveles = {
    Fitness = 5,
    Strength = 5,
    Carpinteria = 6,
    Cocina = 5,
    Punteria = 2,
    Categoria = 0
}
local player = {
    getHoursSurvived = function()
        return 9.4 * 24
    end,
    getPerkLevel = function(_, p)
        return niveles[p.nombre] or 0
    end,
    getUsername = function()
        return "kevin"
    end
}

require "EconomiaArgenta/retos_tab"
local armar = EconomiaArgentaRetosTab.armarFilas

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

local function buscar(filas, prefijo)
    for _, f in ipairs(filas) do
        if f.texto and f.texto:find(prefijo, 1, true) then
            return f
        end
    end
end

print("-- partida normal --")
local datos = {
    activos = true,
    prueba = false,
    kills = 312,
    logrados = {
        kills_50 = true,
        kills_100 = true,
        kills_250 = true,
        dias_3 = true,
        dias_7 = true,
        hab5_1 = true
    },
    cobrados = {
        kills_50 = true,
        kills_100 = true,
        dias_3 = true,
        dias_7 = true,
        hab5_1 = true
    },
    cadaCobrados = 0,
    muertes = 1,
    primeros = {
        primero_kills_1000 = "juan"
    },
    diasMundo = 12
}
local filas = armar(player, datos)
ok("arma filas", #filas > 15, #filas)

local k100 = buscar(filas, "Reto_Kills[100]")
ok("100 kills cobrado", k100 and k100.estado == "cobrado")
local k250 = buscar(filas, "Reto_Kills[250]")
ok("250 kills logrado: listo para reclamar", k250 and k250.estado == "listo" and k250.clave == "kills_250")
ok("aviso arriba: 1 premio para reclamar", filas[1].tipo == "listos" and filas[1].texto:find("[1]", 1, true), filas[1].texto)
local k500 = buscar(filas, "Reto_Kills[500]")
ok("500 kills en progreso", k500 and k500.estado == "progreso")
ok("500 kills: faltan 188", k500 and k500.detalle and k500.detalle:find("188", 1, true), k500 and k500.detalle)
ok("500 kills: barra al 62%", k500 and math.abs(k500.progreso - 312 / 500) < 1e-9)

local d14 = buscar(filas, "Reto_Dias[14")
ok("14 dias en progreso", d14 and d14.estado == "progreso")
ok("14 dias: faltan 4,6", d14 and d14.detalle and d14.detalle:find("4,6", 1, true), d14 and d14.detalle)
local d7 = buscar(filas, "Reto_Dias[7")
ok("7 dias cobrado", d7 and d7.estado == "cobrado")

local il = buscar(filas, "Reto_InicioLimpio")
ok("inicio limpio perdido por morir", il and il.estado == "perdido" and il.detalle:find("PerdidoMuerte", 1, true))

local h3 = buscar(filas, "Reto_HabilidadesVarias")
ok("tres habilidades a 5: 2 de 3 (sin contar Fuerza)", h3 and h3.detalle and h3.detalle:find("2|3", 1, true),
    h3 and h3.detalle)
local h8 = buscar(filas, "Reto_Habilidad[8]")
ok("habilidad a 8: mejor nivel 6", h8 and h8.detalle and h8.detalle:find("6", 1, true), h8 and h8.detalle)

local p1000 = buscar(filas, "Primero_kills[1000]")
ok("primero en 1000 kills: ganado por juan", p1000 and p1000.estado == "ganado" and p1000.detalle:find("juan", 1, true))
local p30 = buscar(filas, "Primero_dias[30")
ok("primero en 30 dias: disponible", p30 and p30.estado == "progreso")

local hayAviso = false
for _, f in ipairs(filas) do
    if f.tipo == "aviso" then
        hayAviso = true
    end
end
ok("sin aviso de modo prueba", not hayAviso)

print("-- modo prueba --")
SandboxVars.EconomiaArgenta.ModoPruebaRetos = true
datos.prueba = true
filas = armar(player, datos)
local hayPrueba = false
for _, f in ipairs(filas) do
    if f.tipo == "aviso" then
        hayPrueba = true
    end
end
ok("muestra el aviso de modo prueba", hayPrueba)
ok("el reto de 50 kills pasa a 1", buscar(filas, "Reto_Kills[1]") ~= nil)

print("-- cada 1000 kills --")
SandboxVars.EconomiaArgenta.ModoPruebaRetos = false
local filasCada = armar(player, {activos = true, kills = 2100, cadaCobrados = 0, logrados = {}, cobrados = {}})
local cada = buscar(filasCada, "Retos_CadaKills")
ok("2100 kills: el recurrente se puede reclamar", cada and cada.estado == "listo" and cada.clave == "kills_cada")
ok("2100 kills: paga 2 vueltas (60)", cada and cada.premio == 60, cada and cada.premio)
filasCada = armar(player, {activos = true, kills = 2100, cadaCobrados = 2, logrados = {}, cobrados = {}})
cada = buscar(filasCada, "Retos_CadaKills")
ok("ya cobrado: vuelve a progreso", cada and cada.estado == "progreso")

print("-- sin datos todavia / vacio --")
filas = armar(player, {
    activos = true
})
ok("no se rompe con datos vacios", #filas > 0)

print("-- textos usados --")
local faltan = {}
local f = io.open(root .. "/mod/EconomiaArgenta/common/media/lua/shared/Translate/AR/IG_UI.json")
local json = f:read("*a")
f:close()
for k in pairs(textos) do
    if not json:find('"' .. k .. '"', 1, true) then
        table.insert(faltan, k)
    end
end
table.sort(faltan)
ok("todos los textos existen en AR", #faltan == 0, table.concat(faltan, ", "))

print("")
print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
