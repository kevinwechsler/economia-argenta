-- Retos individuales de Economia Argenta (lado servidor).
--
-- Premian aguantar, no morir y mejorar el personaje. Cada jugador cobra cada
-- reto una sola vez por partida. Los "primero del server" los cobra solo el
-- primer jugador que los cumple, y se avisa a todos.
--
-- Objetivos y premios: shared/EconomiaArgenta/retos_def.lua.
-- Los retos de kills los paga el motor (defaults/token_rewards.lua); aca solo
-- se lee su contador para los "primero en" y para la pestana Retos.
--
-- Se revisa cada 10 minutos de juego (cada minuto en modo prueba). Todo se
-- guarda en ModData, asi que pertenece a la partida: un wipe lo reinicia.
if isClient() then
    return
end

require "PhunMart/core"
local Commands = require "PhunMart_Server/commands"
local Def = require "EconomiaArgenta/retos_def"
local Core = PhunMart

local Retos = {}
EconomiaArgentaRetos = Retos

-- =========================================================
-- Datos guardados
-- =========================================================

-- La clave de un jugador. En solitario el nombre de usuario es el del
-- personaje y cambia al morir, asi que se usa una constante (igual que el
-- contador de kills del motor).
local SP_KEY = "0"

local function claveJugador(player)
    if Core.isLocal then
        return SP_KEY
    end
    return player:getUsername()
end

local function datos()
    local md = ModData.getOrCreate("EconomiaArgenta_Retos")
    md.jugadores = md.jugadores or {}
    md.primeros = md.primeros or {}
    return md
end

local function datosJugador(player)
    local md = datos()
    local k = claveJugador(player)
    local d = md.jugadores[k]
    if not d then
        d = {
            cobrados = {},
            muertes = 0
        }
        md.jugadores[k] = d
    end
    d.cobrados = d.cobrados or {}
    d.muertes = d.muertes or 0
    return d
end

local function datosKills(player)
    local kr = Core.killRewards
    if not (kr and kr.loaded and kr.getPlayerData) then
        return nil
    end
    return kr:getPlayerData(player:getUsername())
end

-- =========================================================
-- Pagos y avisos
-- =========================================================

local function pagar(player, billetes, reto)
    Core:grantConfigReward(player, {
        item = "Base.Money",
        amount = billetes
    }, "reto " .. tostring(reto.key), reto)
end

--- Avisa a todos los demas jugadores que alguien gano un "primero del server".
local function anunciar(ganador, reto, billetes)
    if Core.isLocal then
        return
    end
    local online = getOnlinePlayers()
    if not online then
        return
    end
    for i = 0, online:size() - 1 do
        local p = online:get(i)
        if p and p ~= ganador then
            sendServerCommand(p, Core.name, "ecoAnuncio", {
                quien = ganador:getUsername(),
                reto = reto,
                amount = billetes
            })
        end
    end
end

local function cobrar(player, d, clave, billetes, reto)
    if d.cobrados[clave] then
        return
    end
    d.cobrados[clave] = true
    pagar(player, billetes, reto)
    Core.debugLn("[Retos] " .. player:getUsername() .. " cobro " .. clave)
end

local function cobrarPrimero(player, def, reto)
    local md = datos()
    if md.primeros[def.clave] then
        return
    end
    md.primeros[def.clave] = player:getUsername()
    reto.primero = true
    pagar(player, def.pago, reto)
    anunciar(player, reto, def.pago)
    Core.debugLn("[Retos] " .. player:getUsername() .. " gano " .. def.clave)
end

-- =========================================================
-- Revision
-- =========================================================

function Retos.revisar(player)
    if not player or player:isDead() then
        return
    end
    local r = Def.actuales()
    local d = datosJugador(player)
    local dias = Def.diasVivo(player)

    -- Dias sin morir
    for _, x in ipairs(r.dias) do
        if dias >= x.dias then
            cobrar(player, d, "dias_" .. x.dias, x.pago, {
                key = "IGUI_EconomiaArgenta_Reto_Dias",
                n = x.dias
            })
        end
    end

    -- Inicio limpio
    local il = r.inicioLimpio
    local diasMundo = getGameTime():getWorldAgeHours() / 24
    if diasMundo >= il.dias and d.muertes == 0 and (player:getHoursSurvived() or 0) >= il.horasMinimas then
        cobrar(player, d, "inicio_limpio", il.pago, {
            key = "IGUI_EconomiaArgenta_Reto_InicioLimpio",
            n = il.dias
        })
    end

    -- Habilidades
    local maximo = 0
    for _, h in ipairs(r.habilidades) do
        local cantidad, max = Def.habilidadesDe(player, h.nivel)
        maximo = max
        if cantidad >= h.cantidad then
            cobrar(player, d, h.clave, h.pago, {
                key = h.cantidad > 1 and "IGUI_EconomiaArgenta_Reto_HabilidadesVarias" or
                    "IGUI_EconomiaArgenta_Reto_Habilidad",
                n = h.nivel,
                m = h.cantidad
            })
        end
    end

    -- Primero del server
    local pk = datosKills(player)
    local kills = pk and pk.zombieKills or 0
    for _, p in ipairs(r.primeros) do
        local cumple = (p.tipo == "kills" and kills >= p.valor) or (p.tipo == "dias" and dias >= p.valor) or
                           (p.tipo == "habilidad" and maximo >= p.valor)
        if cumple then
            cobrarPrimero(player, p, {
                key = "IGUI_EconomiaArgenta_Primero_" .. p.tipo,
                n = p.valor
            })
        end
    end
end

local function revisarTodos()
    if not Def.activos() then
        return
    end
    local online = Core.utils and Core.utils.onlinePlayers and Core.utils.onlinePlayers()
    if not online then
        return
    end
    for i = 0, online:size() - 1 do
        local ok, err = pcall(Retos.revisar, online:get(i))
        if not ok then
            Core.debugLn("[Retos] error: " .. tostring(err))
        end
    end
end

Events.EveryTenMinutes.Add(function()
    if not Def.modoPrueba() then
        revisarTodos()
    end
end)

Events.EveryOneMinute.Add(function()
    if Def.modoPrueba() then
        revisarTodos()
    end
end)

-- Las muertes cuentan para "inicio limpio".
Events.OnCharacterDeath.Add(function(character)
    if not instanceof(character, "IsoPlayer") or character:isAnimal() then
        return
    end
    local d = datosJugador(character)
    d.muertes = d.muertes + 1
end)

-- =========================================================
-- Datos para la pestana Retos
-- =========================================================

--- Lo que el cliente no puede saber solo: kills, retos cobrados, muertes y
--- quien gano cada "primero del server". Dias y habilidades los lee el
--- cliente de su propio personaje.
function Retos.datosPara(player)
    local d = datosJugador(player)
    local pk = datosKills(player)
    local cobradosKills = {}
    for k, v in pairs(pk and pk.claimed or {}) do
        cobradosKills[k] = v
    end
    local cobrados = {}
    for k, v in pairs(d.cobrados) do
        cobrados[k] = v
    end
    local primeros = {}
    for k, v in pairs(datos().primeros) do
        primeros[k] = v
    end
    return {
        activos = Def.activos(),
        prueba = Def.modoPrueba(),
        kills = pk and pk.zombieKills or 0,
        cobradosKills = cobradosKills,
        cobrados = cobrados,
        muertes = d.muertes,
        primeros = primeros,
        diasMundo = getGameTime():getWorldAgeHours() / 24
    }
end

Commands["ecoRetosPedir"] = function(player)
    sendServerCommand(player, Core.name, "ecoRetosDatos", Retos.datosPara(player))
end

return Retos
