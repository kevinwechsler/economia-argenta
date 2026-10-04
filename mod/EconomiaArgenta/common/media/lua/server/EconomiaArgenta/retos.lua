-- Retos de Economia Argenta (lado servidor).
--
-- Individuales (kills, dias sin morir, inicio limpio, habilidades): cada
-- minuto el servidor marca como LOGRADO lo que el jugador ya cumplio, y el
-- jugador cobra apretando "Reclamar" en la pestana Retos. Lo logrado queda
-- guardado: si despues muere, lo puede reclamar igual.
--
-- Primero del server: se paga solo, al primero que lo cumple, y se avisa a
-- todos (si fuera manual, el que llego primero podria perderlo por no apretar).
--
-- Objetivos y premios: shared/EconomiaArgenta/retos_def.lua.
-- Las kills las cuenta el motor (rewards_kill.lua); aca solo se leen.
-- Todo se guarda en ModData: pertenece a la partida, un wipe lo reinicia.
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

-- En solitario el nombre de usuario es el del personaje y cambia al morir,
-- asi que se usa una constante (igual que el contador de kills del motor).
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
        d = {}
        md.jugadores[k] = d
    end
    d.logrados = d.logrados or {}
    d.cobrados = d.cobrados or {}
    d.muertes = d.muertes or 0
    d.cadaCobrados = d.cadaCobrados or 0
    return d
end

local function killsDe(player)
    local kr = Core.killRewards
    if not (kr and kr.loaded and kr.getPlayerData) then
        return 0
    end
    local pd = kr:getPlayerData(player:getUsername())
    return pd and pd.zombieKills or 0
end

-- =========================================================
-- Catalogo de retos individuales: clave, premio y aviso
-- =========================================================

--- Lista de retos individuales con lo que hace falta para pagarlos.
--- `cumple(ctx)` dice si el jugador lo logro ahora mismo.
local function individuales(r)
    local lista = {}
    for _, k in ipairs(r.kills) do
        table.insert(lista, {
            clave = "kills_" .. k.kills,
            pago = k.pago,
            reto = {
                key = "IGUI_EconomiaArgenta_Reto_Kills",
                n = k.kills
            },
            cumple = function(ctx)
                return ctx.kills >= k.kills
            end
        })
    end
    for _, x in ipairs(r.dias) do
        table.insert(lista, {
            clave = "dias_" .. x.dias,
            pago = x.pago,
            reto = {
                key = "IGUI_EconomiaArgenta_Reto_Dias",
                n = x.dias
            },
            cumple = function(ctx)
                return ctx.dias >= x.dias
            end
        })
    end
    local il = r.inicioLimpio
    table.insert(lista, {
        clave = "inicio_limpio",
        pago = il.pago,
        reto = {
            key = "IGUI_EconomiaArgenta_Reto_InicioLimpio",
            n = il.dias
        },
        cumple = function(ctx)
            return ctx.diasMundo >= il.dias and ctx.muertes == 0 and ctx.horas >= il.horasMinimas
        end
    })
    for _, h in ipairs(r.habilidades) do
        table.insert(lista, {
            clave = h.clave,
            pago = h.pago,
            reto = {
                key = h.cantidad > 1 and "IGUI_EconomiaArgenta_Reto_HabilidadesVarias" or
                    "IGUI_EconomiaArgenta_Reto_Habilidad",
                n = h.nivel,
                m = h.cantidad
            },
            cumple = function(ctx)
                return Def.habilidadesDe(ctx.player, h.nivel) >= h.cantidad
            end
        })
    end
    return lista
end

local function contexto(player, d)
    local _, maxNivel = Def.habilidadesDe(player, 1)
    return {
        player = player,
        kills = killsDe(player),
        dias = Def.diasVivo(player),
        horas = player:getHoursSurvived() or 0,
        diasMundo = getGameTime():getWorldAgeHours() / 24,
        muertes = d.muertes,
        maxNivel = maxNivel
    }
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

-- =========================================================
-- Revision periodica: marca logrados y paga los "primero del server"
-- =========================================================

function Retos.revisar(player)
    if not player or player:isDead() then
        return
    end
    local r = Def.actuales()
    local d = datosJugador(player)
    local ctx = contexto(player, d)

    for _, x in ipairs(individuales(r)) do
        if not d.logrados[x.clave] and x.cumple(ctx) then
            d.logrados[x.clave] = true
            Core.debugLn("[Retos] " .. player:getUsername() .. " logro " .. x.clave)
        end
    end

    local md = datos()
    for _, p in ipairs(r.primeros) do
        if not md.primeros[p.clave] then
            local cumple = (p.tipo == "kills" and ctx.kills >= p.valor) or (p.tipo == "dias" and ctx.dias >= p.valor) or
                               (p.tipo == "habilidad" and ctx.maxNivel >= p.valor)
            if cumple then
                md.primeros[p.clave] = player:getUsername()
                local reto = {
                    key = "IGUI_EconomiaArgenta_Primero_" .. p.tipo,
                    n = p.valor,
                    primero = true
                }
                pagar(player, p.pago, reto)
                anunciar(player, reto, p.pago)
                Core.debugLn("[Retos] " .. player:getUsername() .. " gano " .. p.clave)
            end
        end
    end
end

Events.EveryOneMinute.Add(function()
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
-- Reclamar
-- =========================================================

--- Cobra un reto individual ya logrado. "kills_cada" cobra todas las vueltas
--- de "cada N kills" que haya pendientes. Devuelve true si pago algo.
function Retos.reclamar(player, clave)
    if not Def.activos() or not player or player:isDead() or type(clave) ~= "string" then
        return false
    end
    -- Revisar antes, por si lo logro hace segundos y la revision no paso.
    Retos.revisar(player)
    local r = Def.actuales()
    local d = datosJugador(player)

    if clave == "kills_cada" then
        local cada = r.killsCada
        local vueltas = math.floor(killsDe(player) / cada.kills)
        local pendientes = vueltas - d.cadaCobrados
        if pendientes <= 0 then
            return false
        end
        d.cadaCobrados = vueltas
        pagar(player, cada.pago * pendientes, {
            key = "IGUI_EconomiaArgenta_Reto_CadaKills",
            n = cada.kills * vueltas
        })
        return true
    end

    if not d.logrados[clave] or d.cobrados[clave] then
        return false
    end
    for _, x in ipairs(individuales(r)) do
        if x.clave == clave then
            d.cobrados[clave] = true
            pagar(player, x.pago, x.reto)
            Core.debugLn("[Retos] " .. player:getUsername() .. " reclamo " .. clave)
            return true
        end
    end
    return false
end

-- =========================================================
-- Datos para la pestana Retos
-- =========================================================

local function copia(t)
    local out = {}
    for k, v in pairs(t or {}) do
        out[k] = v
    end
    return out
end

--- Lo que el cliente no puede saber solo: kills, logrados, cobrados, muertes
--- y quien gano cada "primero del server". Dias y habilidades los lee el
--- cliente de su propio personaje.
function Retos.datosPara(player)
    local d = datosJugador(player)
    return {
        activos = Def.activos(),
        prueba = Def.modoPrueba(),
        kills = killsDe(player),
        logrados = copia(d.logrados),
        cobrados = copia(d.cobrados),
        cadaCobrados = d.cadaCobrados,
        muertes = d.muertes,
        primeros = copia(datos().primeros),
        diasMundo = getGameTime():getWorldAgeHours() / 24
    }
end

Commands["ecoRetosPedir"] = function(player)
    sendServerCommand(player, Core.name, "ecoRetosDatos", Retos.datosPara(player))
end

Commands["ecoRetosReclamar"] = function(player, args)
    Retos.reclamar(player, args and args.clave)
    sendServerCommand(player, Core.name, "ecoRetosDatos", Retos.datosPara(player))
end

return Retos
