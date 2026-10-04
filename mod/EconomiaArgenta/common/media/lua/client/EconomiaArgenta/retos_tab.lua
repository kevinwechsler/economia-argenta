-- Pestana "Retos" en la ventana del personaje de Economia Argenta.
--
-- Cada reto aparece con su estado:
--   en progreso  -> barra y cuanto falta
--   logrado      -> boton "Reclamar" (cobra al instante)
--   cobrado / perdido / ganado por otro (primero del server)
-- Se abre desde la ventana del personaje o con la tecla 0 (configurable en
-- Opciones > Mods > Economia Argenta). Se desplaza con la rueda del mouse o
-- arrastrando la barra de la derecha.
--
-- Kills, logrados, cobrados y ganadores los guarda el servidor y se piden al
-- abrir la pestana (y cada pocos segundos mientras esta abierta). Dias vivo y
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
local ROW = HGT_SMALL + 8
local PAD = 10
local SCROLL_W = 10

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

-- =========================================================
-- Datos y comandos
-- =========================================================

local Estado = {
    datos = nil,
    ultimoPedido = 0
}

local function local_()
    return Core.isLocal and EconomiaArgentaRetos and EconomiaArgentaRetos.datosPara
end

local function pedirDatos(player)
    Estado.ultimoPedido = getTimestampMs()
    if local_() then
        -- Solitario: el servidor vive en este mismo Lua.
        Estado.datos = EconomiaArgentaRetos.datosPara(player)
        return
    end
    sendClientCommand(player, Core.name, "ecoRetosPedir", {})
end

local function reclamar(player, clave)
    if local_() then
        EconomiaArgentaRetos.reclamar(player, clave)
        Estado.datos = EconomiaArgentaRetos.datosPara(player)
        return
    end
    sendClientCommand(player, Core.name, "ecoRetosReclamar", {
        clave = clave
    })
end

ClientCommands["ecoRetosDatos"] = function(args)
    Estado.datos = args
end

-- =========================================================
-- Filas
-- =========================================================

--- Estado de un reto individual segun los datos del servidor.
local function estadoIndividual(d, clave)
    if (d.cobrados or {})[clave] then
        return "cobrado"
    end
    if (d.logrados or {})[clave] then
        return "listo"
    end
    return "progreso"
end

--- Arma las filas de la pestana. Cada fila: {tipo, texto, premio, estado,
--- progreso (0..1), detalle, clave}.
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
        local clave = "kills_" .. k.kills
        local estado = estadoIndividual(d, clave)
        fila({
            clave = clave,
            texto = getText("IGUI_EconomiaArgenta_Reto_Kills", numero(k.kills)),
            premio = k.pago,
            estado = estado,
            progreso = math.min(1, kills / k.kills),
            detalle = estado == "progreso" and t("Faltan", numero(math.max(0, k.kills - kills))) or nil
        })
    end
    local cada = r.killsCada
    local vueltas = math.floor(kills / cada.kills)
    local pendientes = math.max(0, vueltas - (tonumber(d.cadaCobrados) or 0))
    fila({
        clave = "kills_cada",
        texto = t("CadaKills", numero(cada.kills)),
        premio = cada.pago * math.max(1, pendientes),
        estado = pendientes > 0 and "listo" or "progreso",
        progreso = (kills % cada.kills) / cada.kills,
        detalle = pendientes > 1 and t("Veces", tostring(pendientes)) or
            t("Proximo", numero((vueltas + 1) * cada.kills))
    })

    -- Supervivencia
    seccion(t("Supervivencia"), t("DiasVivo", dias(diasVivo)))
    for _, x in ipairs(r.dias) do
        local clave = "dias_" .. x.dias
        local estado = estadoIndividual(d, clave)
        fila({
            clave = clave,
            texto = getText("IGUI_EconomiaArgenta_Reto_Dias", dias(x.dias)),
            premio = x.pago,
            estado = estado,
            progreso = math.min(1, diasVivo / x.dias),
            detalle = estado == "progreso" and t("Faltan", dias(math.max(0, x.dias - diasVivo))) or nil
        })
    end
    local il = r.inicioLimpio
    local diasMundo = tonumber(d.diasMundo) or 0
    local ilFila = {
        clave = "inicio_limpio",
        texto = getText("IGUI_EconomiaArgenta_Reto_InicioLimpio", dias(il.dias)),
        premio = il.pago,
        estado = estadoIndividual(d, "inicio_limpio")
    }
    if ilFila.estado == "progreso" then
        if (tonumber(d.muertes) or 0) > 0 then
            ilFila.estado = "perdido"
            ilFila.detalle = t("PerdidoMuerte")
        elseif diasMundo >= il.dias then
            ilFila.estado = "perdido"
            ilFila.detalle = t("PerdidoTarde")
        else
            ilFila.progreso = diasMundo / il.dias
            ilFila.detalle = t("DiaDelServer", dias(diasMundo))
        end
    end
    fila(ilFila)

    -- Habilidades
    local _, maxNivel, maxNombre = Def.habilidadesDe(player, 1)
    seccion(t("Habilidades"), maxNombre and t("MejorHabilidad", maxNombre, tostring(maxNivel)) or nil)
    for _, h in ipairs(r.habilidades) do
        local estado = estadoIndividual(d, h.clave)
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
            clave = h.clave,
            texto = texto,
            premio = h.pago,
            estado = estado,
            progreso = progreso,
            detalle = estado == "progreso" and detalle or nil
        })
    end

    -- Primero del server (se pagan solos)
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

    -- Cuantos se pueden reclamar: va arriba de todo
    local listos = 0
    for _, f in ipairs(filas) do
        if f.estado == "listo" then
            listos = listos + 1
        end
    end
    if listos > 0 then
        table.insert(filas, 1, {
            tipo = "listos",
            texto = t("ParaReclamar", tostring(listos))
        })
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
    o.botones = {}
    return o
end

function Tab:player()
    return getSpecificPlayer(self.playerNum)
end

function Tab:maxScroll()
    return math.max(0, self.altoContenido - self.height)
end

function Tab:setScroll(y)
    self.scrollY = math.max(0, math.min(self:maxScroll(), y))
end

function Tab:prerender()
    -- La pestana se estira con la ventana del personaje.
    if self.parent and self.parent.height then
        local alto = self.parent.height - self.y
        if alto > 50 and alto ~= self.height then
            self:setHeight(alto)
        end
        if self.parent.width and self.parent.width ~= self.width then
            self:setWidth(self.parent.width)
        end
    end
    ISPanel.prerender(self)
    local player = self:player()
    if player and getTimestampMs() - Estado.ultimoPedido > REFRESCO_MS then
        pedirDatos(player)
    end
end

function Tab:onMouseWheel(del)
    self:setScroll(self.scrollY + del * ROW * 2)
    return true
end

--- Rectangulo de la barra de desplazamiento (nil si todo entra).
function Tab:barra()
    local max = self:maxScroll()
    if max <= 0 then
        return nil
    end
    local x = self.width - SCROLL_W - 2
    local alto = math.max(30, math.floor(self.height * self.height / self.altoContenido))
    local y = math.floor((self.height - alto) * self.scrollY / max)
    return x, y, SCROLL_W, alto
end

function Tab:onMouseDown(x, y)
    -- Barra de desplazamiento
    local bx, by, bw, bh = self:barra()
    if bx and x >= bx - 2 then
        if y >= by and y <= by + bh then
            self.arrastrando = y - by
        else
            -- click en el carril: saltar ahi
            local max = self:maxScroll()
            self:setScroll((y - bh / 2) / (self.height - bh) * max)
        end
        return true
    end
    -- Botones "Reclamar"
    for _, b in ipairs(self.botones) do
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            local player = self:player()
            if player then
                getSoundManager():playUISound("UIActivateButton")
                reclamar(player, b.clave)
            end
            return true
        end
    end
    return false
end

function Tab:onMouseMove(dx, dy)
    if self.arrastrando then
        local _, _, _, bh = self:barra()
        if bh then
            local max = self:maxScroll()
            local y = self:getMouseY() - self.arrastrando
            self:setScroll(y / math.max(1, self.height - bh) * max)
        end
    end
end

function Tab:onMouseMoveOutside(dx, dy)
    self:onMouseMove(dx, dy)
end

function Tab:onMouseUp()
    self.arrastrando = nil
end

function Tab:onMouseUpOutside()
    self.arrastrando = nil
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
    self.botones = {}
    local player = self:player()
    self:setStencilRect(0, 0, self.width, self.height)
    local y = PAD - self.scrollY
    local w = self.width - SCROLL_W - 4

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
    local anchoBoton = getTextManager():MeasureStringX(FONT_SMALL, t("Reclamar")) + 16
    local colEstado = colPremio - 50
    local anchoBarra = math.min(110, math.floor(w * 0.2))
    local mx, my = self:getMouseX(), self:getMouseY()

    for _, f in ipairs(armarFilas(player, d)) do
        if f.tipo == "aviso" then
            self:drawRect(PAD, y, w - 2 * PAD, ROW, 0.35, 0.6, 0.2, 0.1)
            texto(self, f.texto, PAD + 6, y + 4, C_MAL)
            y = y + ROW + 6
        elseif f.tipo == "listos" then
            self:drawRect(PAD, y, w - 2 * PAD, ROW, 0.35, 0.15, 0.45, 0.15)
            texto(self, f.texto, PAD + 6, y + 4, C_OK)
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
            local ty = y + 4
            if f.estado == "cobrado" then
                texto(self, "v", x, ty, C_OK)
                cTexto = C_GRIS
            elseif f.estado == "perdido" or f.estado == "ganado" then
                texto(self, "x", x, ty, C_MAL)
                cTexto = C_GRIS
            elseif f.estado == "listo" then
                texto(self, "!", x, ty, C_OK)
            else
                local p = math.max(0, math.min(1, f.progreso or 0))
                self:drawRect(x, y + 5, anchoBarra, ROW - 10, 0.8, 0.15, 0.15, 0.15)
                if p > 0 then
                    self:drawRect(x, y + 5, math.floor(anchoBarra * p), ROW - 10, 0.9, C_BARRA[1], C_BARRA[2],
                        C_BARRA[3])
                end
                self:drawRectBorder(x, y + 5, anchoBarra, ROW - 10, 0.6, 0.5, 0.5, 0.5)
                x = x + anchoBarra
            end
            x = x + 14
            texto(self, f.texto, x, ty, cTexto)
            if f.detalle then
                local tw = getTextManager():MeasureStringX(FONT_SMALL, f.texto)
                texto(self, "  " .. f.detalle, x + tw, ty, C_GRIS)
            end

            textoDerecha(self, "+" .. tostring(f.premio), colPremio, ty,
                (f.estado == "progreso" or f.estado == "listo") and C_PREMIO or C_GRIS)

            if f.estado == "listo" and f.clave then
                local bx = colEstado - anchoBoton
                local bw, bh = anchoBoton, ROW - 2
                local by = y + 1
                local hover = mx >= bx and mx <= bx + bw and my >= by and my <= by + bh
                self:drawRect(bx, by, bw, bh, 0.95, hover and 0.20 or 0.12, hover and 0.55 or 0.40, hover and 0.20 or 0.14)
                self:drawRectBorder(bx, by, bw, bh, 1, 0.35, 0.85, 0.35)
                local lw = getTextManager():MeasureStringX(FONT_SMALL, t("Reclamar"))
                self:drawText(t("Reclamar"), bx + (bw - lw) / 2, ty, 1, 1, 1, 1, FONT_SMALL)
                if by + bh > 0 and by < self.height then
                    table.insert(self.botones, {
                        x = bx,
                        y = by,
                        w = bw,
                        h = bh,
                        clave = f.clave
                    })
                end
            else
                local estadoTxt = (f.estado == "cobrado" and t("Cobrado")) or (f.estado == "perdido" and t("Perdido")) or
                                      (f.estado == "ganado" and t("Ganado")) or nil
                if estadoTxt then
                    textoDerecha(self, estadoTxt, colEstado, ty, f.estado == "cobrado" and C_OK or C_MAL)
                end
            end
            y = y + ROW
        end
    end

    self.altoContenido = y + self.scrollY + PAD
    if self.scrollY > self:maxScroll() then
        self:setScroll(self.scrollY)
    end

    -- Barra de desplazamiento
    local bx, by, bw, bh = self:barra()
    if bx then
        self:drawRect(bx, 0, bw, self.height, 0.5, 0.1, 0.1, 0.1)
        self:drawRect(bx, by, bw, bh, 0.9, 0.5, 0.5, 0.5)
    end
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
