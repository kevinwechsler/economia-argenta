-- Opcion de admin: click derecho en el mundo -> "Recibir las 3 tiendas".
--
-- Pone en el inventario del admin una Armeria, una Ferreteria y un Compro Oro
-- para colocarlas como mueble. Solo aparece para admins (o en solitario /
-- modo debug). El servidor vuelve a chequear que sea admin.
if isServer() then
    return
end

require "PhunMart/core"
local Core = PhunMart

local function esAdmin(player)
    return Core.utils and Core.utils.isAdmin and Core.utils.isAdmin(player)
end

local function darTiendas(player)
    sendClientCommand(player, Core.name, "ecoDarTiendas", {})
end

Events.OnFillWorldObjectContextMenu.Add(function(playerNum, context, worldobjects, test)
    if test then
        return
    end
    local player = getSpecificPlayer(playerNum)
    if not player or not esAdmin(player) then
        return
    end
    context:addOption(getText("IGUI_EconomiaArgenta_Admin_DarTiendas"), player, darTiendas)
end)
