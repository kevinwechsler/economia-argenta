-- Retos individuales de Economia Argenta (lado servidor).
--
-- Premian aguantar, no morir y mejorar el personaje. Cada jugador cobra cada
-- reto una sola vez por partida. Los retos "primero del server" los cobra solo
-- el primer jugador que los cumple, y se avisa a todos.
--
-- Los retos de kills estan en defaults/token_rewards.lua (usan el contador de
-- kills del motor); aca solo se lee ese contador para los "primero en".
--
-- Se revisa cada 10 minutos de juego. Todo se guarda en ModData, asi que
-- pertenece a la partida: un wipe lo reinicia.
--
-- Se activa con la misma opcion que los retos de kills
-- (EconomiaArgenta.RecompensasKills).
if isClient() then
    return
end

require "PhunMart/core"
local Core = PhunMart

local Retos = {}
EconomiaArgentaRetos = Retos

-- =========================================================
-- Definicion de los retos (montos en billetes)
-- =========================================================

-- Dias seguidos sin morir con el mismo personaje.
Retos.dias = {{
    dias = 3,
    pago = 5
}, {
    dias = 7,
    pago = 15
}, {
    dias = 14,
    pago = 35
}, {
    dias = 30,
    pago = 80
}, {
    dias = 60,
    pago = 160
}}

-- No morir nunca durante los primeros N dias del server.
Retos.inicioLimpio = {
    dias = 5,
    pago = 20,
    -- Tiene que haber jugado al menos esto con su personaje, para que no lo
    -- cobre alguien que entra el dia 4.
    horasMinimas = 72
}

-- Habilidades (no cuentan Fuerza ni Estado fisico, que arrancan en 5).
Retos.habilidades = {{
    clave = "hab5_1",
    nivel = 5,
    cantidad = 1,
    pago = 5
}, {
    clave = "hab5_3",
    nivel = 5,
    cantidad = 3,
    pago = 12
}, {
    clave = "hab8_1",
    nivel = 8,
    cantidad = 1,
    pago = 25
}, {
    clave = "hab10_1",
    nivel = 10,
    cantidad = 1,
    pago = 50
}}

-- Primero del server: premio unico para todo el server.
Retos.primeros = {{
    clave = "primero_kills_1000",
    tipo = "kills",
    valor = 1000,
    pago = 80
}, {
    clave = "primero_kills_2500",
    tipo = "kills",
    valor = 2500,
    pago = 150
}, {
    clave = "primero_dias_30",
    tipo = "dias",
    valor = 30,
    pago = 100
}, {
    clave = "primero_hab_10",
    tipo = "habilidad",
    valor = 10,
    pago = 80
}}

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

local function activos()
    local vars = SandboxVars and SandboxVars.EconomiaArgenta
    return vars and vars.RecompensasKills == true
end

-- =========================================================
-- Lectura del personaje
-- =========================================================

local function diasVivo(player)
    return (player:getHoursSurvived() or 0) / 24
end

-- Fuerza y Estado fisico arrancan en 5 y suben solos: no cuentan.
local function esHabilidadActiva(perk)
    if perk == Perks.Fitness or perk == Perks.Strength then
        return false
    end
    return perk:getParent() ~= Perks.None
end

--- Cuantas habilidades activas tiene en `nivel` o mas, y el nivel mas alto.
local function habilidades(player, nivel)
    local cantidad, maximo = 0, 0
    for i = 0, PerkFactory.PerkList:size() - 1 do
        local perk = PerkFactory.PerkList:get(i)
        if perk and esHabilidadActiva(perk) then
            local lv = player:getPerkLevel(perk) or 0
            if lv >= nivel then
                cantidad = cantidad + 1
            end
            if lv > maximo then
                maximo = lv
            end
        end
    end
    return cantidad, maximo
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

--- Cobra un reto individual si todavia no lo cobro.
local function cobrar(player, d, clave, billetes, reto)
    if d.cobrados[clave] then
        return
    end
    d.cobrados[clave] = true
    pagar(player, billetes, reto)
    Core.debugLn("[Retos] " .. player:getUsername() .. " cobro " .. clave)
end

--- Cobra un "primero del server" si nadie lo gano todavia.
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
    local d = datosJugador(player)
    local dias = diasVivo(player)

    -- Dias sin morir
    for _, r in ipairs(Retos.dias) do
        if dias >= r.dias then
            cobrar(player, d, "dias_" .. r.dias, r.pago, {
                key = "IGUI_EconomiaArgenta_Reto_Dias",
                n = r.dias
            })
        end
    end

    -- Inicio limpio
    local il = Retos.inicioLimpio
    local diasMundo = getGameTime():getWorldAgeHours() / 24
    if diasMundo >= il.dias and d.muertes == 0 and (player:getHoursSurvived() or 0) >= il.horasMinimas then
        cobrar(player, d, "inicio_limpio", il.pago, {
            key = "IGUI_EconomiaArgenta_Reto_InicioLimpio",
            n = il.dias
        })
    end

    -- Habilidades
    local maximo = 0
    for _, r in ipairs(Retos.habilidades) do
        local cantidad, max = habilidades(player, r.nivel)
        maximo = max
        if cantidad >= r.cantidad then
            cobrar(player, d, r.clave, r.pago, {
                key = r.cantidad > 1 and "IGUI_EconomiaArgenta_Reto_HabilidadesVarias" or
                    "IGUI_EconomiaArgenta_Reto_Habilidad",
                n = r.nivel,
                m = r.cantidad
            })
        end
    end

    -- Primero del server
    local kills = killsDe(player)
    for _, def in ipairs(Retos.primeros) do
        local cumple = (def.tipo == "kills" and kills >= def.valor) or (def.tipo == "dias" and dias >= def.valor) or
                           (def.tipo == "habilidad" and maximo >= def.valor)
        if cumple then
            cobrarPrimero(player, def, {
                key = "IGUI_EconomiaArgenta_Primero_" .. def.tipo,
                n = def.valor
            })
        end
    end
end

Events.EveryTenMinutes.Add(function()
    if not activos() then
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

return Retos
