-- Definicion de TODOS los retos de Economia Argenta (montos en billetes).
--
-- Es el unico lugar donde se tocan objetivos y premios. Lo usan:
--   defaults/token_rewards.lua      -> pagos de kills (motor)
--   server/EconomiaArgenta/retos.lua -> dias, inicio limpio, habilidades, primeros
--   client/EconomiaArgenta/retos_tab.lua -> la pestana "Retos" del personaje
--
-- Modo prueba (sandbox EconomiaArgenta.ModoPruebaRetos): divide kills y dias
-- por PRUEBA_DIVISOR y baja los niveles de habilidad a 1, para probar todo en
-- minutos. Los premios no cambian.
local Def = {}

Def.PRUEBA_DIVISOR = 50

Def.kills = {{
    kills = 50,
    pago = 3
}, {
    kills = 100,
    pago = 8
}, {
    kills = 250,
    pago = 20
}, {
    kills = 500,
    pago = 35
}, {
    kills = 1000,
    pago = 60
}, {
    kills = 2500,
    pago = 120
}}

-- Despues del ultimo, cada N kills mas.
Def.killsCada = {
    kills = 1000,
    pago = 30
}

-- Dias seguidos sin morir con el mismo personaje.
Def.dias = {{
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

-- No morir nunca durante los primeros N dias del server, habiendo jugado al
-- menos `horasMinimas` con el personaje (para que no lo cobre alguien que
-- entra el ultimo dia).
Def.inicioLimpio = {
    dias = 5,
    horasMinimas = 72,
    pago = 20
}

-- Habilidades (no cuentan Fuerza ni Estado fisico, que arrancan en 5).
Def.habilidades = {{
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
Def.primeros = {{
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

function Def.activos()
    local vars = SandboxVars and SandboxVars.EconomiaArgenta
    return vars ~= nil and vars.RecompensasKills == true
end

function Def.modoPrueba()
    local vars = SandboxVars and SandboxVars.EconomiaArgenta
    return vars ~= nil and vars.ModoPruebaRetos == true
end

local function copiar(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = type(v) == "table" and copiar(v) or v
    end
    return out
end

local function kills(n, prueba)
    return prueba and math.max(1, math.floor(n / Def.PRUEBA_DIVISOR)) or n
end

local function dias(n, prueba)
    return prueba and n / Def.PRUEBA_DIVISOR or n
end

local function nivel(n, prueba)
    return prueba and 1 or n
end

--- Los retos con los objetivos que aplican ahora (escalados en modo prueba).
--- Siempre devuelve una copia: se puede modificar sin tocar la definicion.
function Def.actuales()
    local prueba = Def.modoPrueba()
    local r = {
        prueba = prueba,
        kills = {},
        killsCada = copiar(Def.killsCada),
        dias = {},
        inicioLimpio = copiar(Def.inicioLimpio),
        habilidades = {},
        primeros = {}
    }
    for _, k in ipairs(Def.kills) do
        table.insert(r.kills, {
            kills = kills(k.kills, prueba),
            pago = k.pago
        })
    end
    r.killsCada.kills = kills(Def.killsCada.kills, prueba)
    for _, d in ipairs(Def.dias) do
        table.insert(r.dias, {
            dias = dias(d.dias, prueba),
            pago = d.pago
        })
    end
    r.inicioLimpio.dias = dias(Def.inicioLimpio.dias, prueba)
    r.inicioLimpio.horasMinimas = prueba and Def.inicioLimpio.horasMinimas / Def.PRUEBA_DIVISOR or
                                      Def.inicioLimpio.horasMinimas
    for _, h in ipairs(Def.habilidades) do
        local c = copiar(h)
        c.nivel = nivel(h.nivel, prueba)
        table.insert(r.habilidades, c)
    end
    for _, p in ipairs(Def.primeros) do
        local c = copiar(p)
        if p.tipo == "kills" then
            c.valor = kills(p.valor, prueba)
        elseif p.tipo == "dias" then
            c.valor = dias(p.valor, prueba)
        else
            c.valor = nivel(p.valor, prueba)
        end
        table.insert(r.primeros, c)
    end
    return r
end

-- =========================================================
-- Lectura del personaje (sirve en cliente y servidor)
-- =========================================================

function Def.diasVivo(player)
    return (player:getHoursSurvived() or 0) / 24
end

-- Fuerza y Estado fisico arrancan en 5 y suben solos: no cuentan.
local function esHabilidadActiva(perk)
    if perk == Perks.Fitness or perk == Perks.Strength then
        return false
    end
    return perk:getParent() ~= Perks.None
end

--- Cuantas habilidades activas tiene en `nivel` o mas, la mas alta y su nombre.
function Def.habilidadesDe(player, nivelMinimo)
    local cantidad, maximo, nombre = 0, 0, nil
    for i = 0, PerkFactory.PerkList:size() - 1 do
        local perk = PerkFactory.PerkList:get(i)
        if perk and esHabilidadActiva(perk) then
            local lv = player:getPerkLevel(perk) or 0
            if lv >= nivelMinimo then
                cantidad = cantidad + 1
            end
            if lv > maximo then
                maximo = lv
                nombre = perk:getName()
            end
        end
    end
    return cantidad, maximo, nombre
end

return Def
