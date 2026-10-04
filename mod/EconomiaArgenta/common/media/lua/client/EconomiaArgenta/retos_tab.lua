-- Pestana "Retos" en la ventana del personaje de Economia Argenta.
--
-- Muestra cada reto con su estado: cobrado, en progreso (con barra y cuanto
-- falta), perdido, o, para los "primero del server", quien lo gano.
-- Se abre desde la ventana del personaje o con la tecla 0 (configurable en
-- Opciones > Mods > Economia Argenta).
--
-- Kills, retos cobrados y ganadores los guarda el servidor y se piden al abrir
-- la pestana (y cada pocos segundos mientras esta abierta). Dias vivo y
-- habilidades se leen del propio personaje.
if isServer() then
    return
end

require "ISUI/ISPanel"
require "PhunMart/core"
local Def = require "EconomiaArgenta/retos_def"
local ClientCommands = require "PhunMart_Client/commands"
local Core = PhunMart

local TAB_NAME = "EconomiaArgentaRetos"
local VIEW_NAME = TAB_NAME .. "View"
local REFRESCO_MS = 3000

local FONT_SMALL = UIFont.Small
local FONT_MEDIUM = UIFont.Medium
local HGT_SMALL = getTextManager():getFontHeight(FONT_SMALL)
local HGT_MEDIUM = getTextManager():getFontHeight(FONT_MEDIUM)
local ROW = HGT_SMALL + 6
local PAD = 10

-- Colores
local C_TITULO = {0.95, 0.80, 0.35}
local C_TEXTO = {0.90, 0.90, 0.90}
local C_GRIS = {0.55, 0.55, 0.55}
local C_OK = {0.45, 0.85, 0.45}
local C_MAL = {0.85, 0.40, 0.40}
local C_PREMIO = {0.95, 0.80, 0.35}
local C_BARRA = {0.40, 0.70, 0.40}

local function t(key, ...)
    return getText("IGUI_EconomiaArgenta_Retos_" .. key, ...)
end

local function numero(n)
    n = math.floor(tonumber(n) or 0)
    if Core.utils and Core.utils.formatWholeNumber then
        return Core.utils.formatWholeNumber(n)
    end
    return tostring(n)
end

local function dias(v)
    v = tonumber(v) or 0
    local s = v < 1 and string.format("%.2f", v) or string.format("%.1f", v)
    return (s:gsub("%.", ","))
end

local function premio(n)
    return "+" .. tostring(n)
end

-- =========================================================
-- Datos
-- =========================================================

local Estado = {
    datos = nil,
    ultimoPedido = 0
}

local function pedirDatos(player)
    Estado.ultimoPedido = getTimestampMs()
    if Core.isLocal and EconomiaArgentaRetos and EconomiaArgentaRetos.datosPara then
        -- Solitario: el servidor vive en este mismo Lua.
        Estado.datos = EconomiaArgentaRetos.datosPara(player)
        return
    end
    sendClientCommand(player, Core.name, "ecoRetosPedir", {})
end

ClientCommands["ecoRetosDatos"] = function(args)
    Estado.datos = args
end

--- Arma las filas de la pestana. Cada fila: {tipo, texto, premio, estado,
--- progreso (0..1), detalle}.
local function armarFilas(player, d)
    local filas = {}
    local function seccion(texto, extra)
        table.insert(filas, {
            tipo = "seccion",
            texto = texto,
            detalle = extra
        })
    end
    local function fila(f)
        f.tipo = "reto"
        table.insert(filas, f)
    end

    local r = Def.actuales()
    local cobrados = d.cobrados or {}
    local cobradosKills = d.cobradosKills or {}
    local primeros = d.primeros or {}
    local kills = tonumber(d.kills) or 0
    local diasVivo = Def.diasVivo(player)

    if d.prueba then
        table.insert(filas, {
            tipo = "aviso",
            texto = t("ModoPrueba", tostring(Def.PRUEBA_DIVISOR))
        })
    end

    -- Kills
    seccion(t("Kills"), t("TusKills", numero(kills)))
    for _, k in ipairs(r.kills) do
        local hecho = cobradosKills["zombie_" .. k.kills] ~= nil
        fila({
            texto = getText("IGUI_EconomiaArgenta_Reto_Kills", numero(k.kills)),
            premio = k.pago,
            estado = hecho and "cobrado" or "progreso",
            progreso = math.min(1, kills / k.kills),
            detalle = not hecho and t("Faltan", numero(math.max(0, k.kills - kills))) or nil
        })
    end
    local cada = r.killsCada
    local proximo = (math.floor(kills / cada.kills) + 1) * cada.kills
    fila({
        texto = t("CadaKills", numero(cada.kills)),
        premio = cada.pago,
        estado = "progreso",
        progreso = (kills % cada.kills) / cada.kills,
        detalle = t("Proximo", numero(proximo))
    })

    -- Supervivencia
    seccion(t("Supervivencia"), t("DiasVivo", dias(diasVivo)))
    for _, x in ipairs(r.dias) do
        local hecho = cobrados["dias_" .. x.dias] ~= nil
        fila({
            texto = getText("IGUI_EconomiaArgenta_Reto_Dias", dias(x.dias)),
            premio = x.pago,
            estado = hecho and "cobrado" or "progreso",
            progreso = math.min(1, diasVivo / x.dias),
            detalle = not hecho and t("Faltan", dias(math.max(0, x.dias - diasVivo))) or nil
        })
    end
    local il = r.inicioLimpio
    local diasMundo = tonumber(d.diasMundo) or 0
    local ilFila = {
        texto = getText("IGUI_EconomiaArgenta_Reto_InicioLimpio", dias(il.dias)),
        premio = il.pago
    }
    if cobrados["inicio_limpio"] then
        ilFila.estado = "cobrado"
    elseif (tonumber(d.muertes) or 0) > 0 then
        ilFila.estado = "perdido"
        ilFila.detalle = t("PerdidoMuerte")
    elseif diasMundo >= il.dias then
        ilFila.estado = "perdido"
        ilFila.detalle = t("PerdidoTarde")
    else
        ilFila.estado = "progreso"
        ilFila.progreso = diasMundo / il.dias
        ilFila.detalle = t("DiaDelServer", dias(diasMundo))
    end
    fila(ilFila)

    -- Habilidades
    local _, maxNivel, maxNombre = Def.habilidadesDe(player, 1)
    seccion(t("Habilidades"), maxNombre and t("MejorHabilidad", maxNombre, tostring(maxNivel)) or nil)
    for _, h in ipairs(r.habilidades) do
        local hecho = cobrados[h.clave] ~= nil
        local cantidad = Def.habilidadesDe(player, h.nivel)
        local texto = h.cantidad > 1 and
                          getText("IGUI_EconomiaArgenta_Reto_HabilidadesVarias", tostring(h.nivel), tostring(h.cantidad)) or
                          getText("IGUI_EconomiaArgenta_Reto_Habilidad", tostring(h.nivel))
        local progreso, detalle
        if h.cantidad > 1 then
            progreso = math.min(1, cantidad / h.cantidad)
            detalle = t("DeTantas", tostring(math.min(cantidad, h.cantidad)), tostring(h.cantidad))
        else
            progreso = math.min(1, maxNivel / h.nivel)
            detalle = t("NivelActual", tostring(maxNivel))
        end
        fila({
            texto = texto,
            premio = h.pago,
            estado = hecho and "cobrado" or "progreso",
            progreso = progreso,
            detalle = not hecho and detalle or nil
        })
    end

    -- Primero del server
    seccion(t("Primeros"), t("PrimerosAyuda"))
    local yo = player:getUsername()
    for _, p in ipairs(r.primeros) do
        local ganador = primeros[p.clave]
        local valor = p.tipo == "dias" and dias(p.valor) or numero(p.valor)
        local f = {
            texto = getText("IGUI_EconomiaArgenta_Primero_" .. p.tipo, valor),
            premio = p.pago
        }
        if ganador then
            f.estado = ganador == yo and "cobrado" or "ganado"
            f.detalle = ganador == yo and t("GanadoPorVos") or t("GanadoPor", tostring(ganador))
        else
            local actual = (p.tipo == "kills" and kills) or (p.tipo == "dias" and diasVivo) or maxNivel
            f.estado = "progreso"
            f.progreso = math.min(1, actual / p.valor)
            f.detalle = t("Disponible")
        end
        fila(f)
    end

    return filas
end

-- =========================================================
-- Panel
-- =========================================================

EconomiaArgentaRetosTab = ISPanel:derive("EconomiaArgentaRetosTab")
local Tab = EconomiaArgentaRetosTab
Tab.armarFilas = armarFilas -- expuesto para tests/test_retos_tab.lua

function Tab:new(x, y, width, height, playerNum)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum
    o.backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 0.8
    }
    o.borderColor = {
        r = 0.4,
        g = 0.4,
        b = 0.4,
        a = 0
    }
    o.scrollY = 0
    o.altoContenido = 0
    return o
end

function Tab:player()
    return getSpecificPlayer(self.playerNum)
end

function Tab:prerender()
    ISPanel.prerender(self)
    local player = self:player()
    if player and getTimestampMs() - Estado.ultimoPedido > REFRESCO_MS then
        pedirDatos(player)
    end
end

function Tab:onMouseWheel(del)
    local maximo = math.max(0, self.altoContenido - self.height)
    self.scrollY = math.max(0, math.min(maximo, self.scrollY + del * ROW * 2))
    return true
end

local function texto(self, s, x, y, c, font)
    self:drawText(s, x, y, c[1], c[2], c[3], 1, font or FONT_SMALL)
end

local function textoDerecha(self, s, xDerecha, y, c, font)
    local w = getTextManager():MeasureStringX(font or FONT_SMALL, s)
    self:drawText(s, xDerecha - w, y, c[1], c[2], c[3], 1, font or FONT_SMALL)
end

function Tab:render()
    ISPanel.render(self)
    local player = self:player()
    self:setStencilRect(0, 0, self.width, self.height)
    local y = PAD - self.scrollY
    local w = self.width

    texto(self, t("Titulo"), PAD, y, C_TITULO, FONT_MEDIUM)
    y = y + HGT_MEDIUM + 6

    local d = Estado.datos
    if not player or not d then
        texto(self, t("Cargando"), PAD, y, C_GRIS)
        self:clearStencilRect()
        return
    end
    if d.activos == false then
        texto(self, t("Apagados"), PAD, y, C_GRIS)
        self:clearStencilRect()
        return
    end

    local colPremio = w - PAD
    local colEstado = colPremio - 60
    local anchoBarra = math.min(120, math.floor(w * 0.22))

    for _, f in ipairs(armarFilas(player, d)) do
        if f.tipo == "aviso" then
            self:drawRect(PAD, y, w - 2 * PAD, ROW, 0.35, 0.6, 0.2, 0.1)
            texto(self, f.texto, PAD + 6, y + 3, C_MAL)
            y = y + ROW + 6
        elseif f.tipo == "seccion" then
            y = y + 6
            texto(self, f.texto, PAD, y, C_TITULO, FONT_MEDIUM)
            if f.detalle then
                textoDerecha(self, f.detalle, w - PAD, y + (HGT_MEDIUM - HGT_SMALL), C_GRIS)
            end
            y = y + HGT_MEDIUM + 2
            self:drawRect(PAD, y, w - 2 * PAD, 1, 0.5, 0.6, 0.6, 0.6)
            y = y + 4
        else
            local x = PAD
            local cTexto = C_TEXTO
            if f.estado == "cobrado" then
                texto(self, "v", x, y + 3, C_OK)
                cTexto = C_GRIS
            elseif f.estado == "perdido" or f.estado == "ganado" then
                texto(self, "x", x, y + 3, C_MAL)
                cTexto = C_GRIS
            else
                -- barra de progreso
                local p = math.max(0, math.min(1, f.progreso or 0))
                self:drawRect(x, y + 4, anchoBarra, ROW - 8, 0.8, 0.15, 0.15, 0.15)
                if p > 0 then
                    self:drawRect(x, y + 4, math.floor(anchoBarra * p), ROW - 8, 0.9, C_BARRA[1], C_BARRA[2],
                        C_BARRA[3])
                end
                self:drawRectBorder(x, y + 4, anchoBarra, ROW - 8, 0.6, 0.5, 0.5, 0.5)
                x = x + anchoBarra
            end
            x = x + 14
            texto(self, f.texto, x, y + 3, cTexto)
            if f.detalle then
                local tw = getTextManager():MeasureStringX(FONT_SMALL, f.texto)
                texto(self, "  " .. f.detalle, x + tw, y + 3, C_GRIS)
            end
            local estadoTxt = (f.estado == "cobrado" and t("Cobrado")) or (f.estado == "perdido" and t("Perdido")) or
                                  (f.estado == "ganado" and t("Ganado")) or nil
            if estadoTxt then
                textoDerecha(self, estadoTxt, colEstado, y + 3, f.estado == "cobrado" and C_OK or C_MAL)
            end
            textoDerecha(self, premio(f.premio), colPremio, y + 3, f.estado == "progreso" and C_PREMIO or C_GRIS)
            y = y + ROW
        end
    end

    self.altoContenido = y + self.scrollY + PAD
    self:clearStencilRect()
end

-- =========================================================
-- Pestana en la ventana del personaje
-- =========================================================

local function etiqueta()
    return getText("IGUI_EconomiaArgenta_Retos_Tab")
end

local function agregarA(win)
    if not win or not win.panel or win[VIEW_NAME] then
        return
    end
    win[VIEW_NAME] = Tab:new(0, 8, win.width, win.height - 8, win.playerNum)
    win[VIEW_NAME]:initialise()
    win[VIEW_NAME].infoText = getText("IGUI_EconomiaArgenta_Retos_Info")
    win.panel:addView(etiqueta(), win[VIEW_NAME])
end

local createChildrenOriginal = ISCharacterInfoWindow.createChildren
function ISCharacterInfoWindow:createChildren()
    createChildrenOriginal(self)
    agregarA(self)
end

local onTabTornOffOriginal = ISCharacterInfoWindow.onTabTornOff
function ISCharacterInfoWindow:onTabTornOff(view, window)
    if self.playerNum == 0 and view == self[VIEW_NAME] then
        ISLayoutManager.RegisterWindow("charinfowindow." .. TAB_NAME, ISCollapsableWindow, window)
    end
    onTabTornOffOriginal(self, view, window)
end

-- Por si la ventana ya existia cuando cargo el mod.
Events.OnCreatePlayer.Add(function(playerNum)
    agregarA(getPlayerInfoPanel(playerNum))
end)

-- =========================================================
-- Tecla para abrir (Opciones > Mods > Economia Argenta)
-- =========================================================

local opciones = nil
if PZAPI and PZAPI.ModOptions then
    opciones = PZAPI.ModOptions:create("EconomiaArgenta", "Economía Argenta")
    opciones.abrirRetos = opciones:addKeyBind("AbrirRetos", getText("IGUI_EconomiaArgenta_Retos_Tecla"), Keyboard.KEY_0,
        getText("IGUI_EconomiaArgenta_Retos_Tecla_tooltip"))
end

local function teclaRetos()
    if opciones and opciones.abrirRetos then
        return opciones.abrirRetos:getValue()
    end
    return Keyboard.KEY_0
end

Events.OnKeyPressed.Add(function(key)
    if key ~= teclaRetos() then
        return
    end
    local player = getSpecificPlayer(0)
    if not player or player:isDead() then
        return
    end
    local win = getPlayerInfoPanel(0)
    if not win then
        return
    end
    agregarA(win)
    pedirDatos(player)
    win:toggleView(etiqueta())
end)
