-- Cambiar precios desde la tienda (solo admin).
--
-- Click derecho sobre un producto en la ventana de la tienda:
--   "Cambiar precio..."  -> cuantos billetes cuesta (Armeria, Ferreteria)
--   "Cambiar pago..."    -> cuantos billetes paga (Compro Oro)
--   "Volver al precio original"
--
-- Se guarda con el sistema de ajustes del motor (archivo PhunMart_Items.json
-- en la carpeta Lua del server), asi que sobrevive a reinicios y updates del
-- mod. Despues se reponen todas las maquinas para que muestren el precio nuevo.
if isClient() then
    return
end

require "PhunMart/core"
local Commands = require "PhunMart_Server/commands"
local Core = PhunMart

local MAX_BILLETES = 999

local function esAdmin(player)
    return player and Core.utils and Core.utils.isAdmin and Core.utils.isAdmin(player)
end

local function actualizarMaquinas()
    local sys = Core.ServerSystem and Core.ServerSystem.instance
    if sys and sys.restockAll then
        sys:restockAll()
    end
end

Commands["ecoCambiarPrecio"] = function(player, args)
    if not esAdmin(player) or type(args) ~= "table" or type(args.item) ~= "string" then
        return
    end
    local n = math.floor(tonumber(args.billetes) or 0)
    if n < 1 or n > MAX_BILLETES then
        return
    end
    local def
    if args.pago then
        def = {
            reward = "eco_pago_" .. n
        }
    else
        def = {
            price = "eco_" .. n
        }
    end
    Core.ServerSystem.instance:upsertDefinition(Core.primaryOverride("items"), "items", args.item, def)
    actualizarMaquinas()
    print("[EconomiaArgenta] " .. player:getUsername() .. " cambio " .. args.item .. " a " .. n ..
              (args.pago and " billetes de pago" or " billetes"))
end

-- "Recibir las 3 tiendas" (client/EconomiaArgenta/admin_tiendas.lua): pone
-- las maquinas en el inventario del admin para colocarlas como mueble.
local TIENDAS = {"PhunMart.PittyTheTool", "PhunMart.FinalAmendment", "PhunMart.PrawnStars"}

Commands["ecoDarTiendas"] = function(player)
    if not esAdmin(player) then
        return
    end
    local inv = player:getInventory()
    for _, tipo in ipairs(TIENDAS) do
        local item = inv:AddItem(tipo)
        if item then
            sendAddItemToContainer(inv, item)
        end
    end
    print("[EconomiaArgenta] " .. player:getUsername() .. " recibio las 3 tiendas")
end

Commands["ecoPrecioOriginal"] = function(player, args)
    if not esAdmin(player) or type(args) ~= "table" or type(args.item) ~= "string" then
        return
    end
    Core.ServerSystem.instance:deleteDefinition(Core.primaryOverride("items"), args.item)
    actualizarMaquinas()
    print("[EconomiaArgenta] " .. player:getUsername() .. " restauro el precio de " .. args.item)
end
