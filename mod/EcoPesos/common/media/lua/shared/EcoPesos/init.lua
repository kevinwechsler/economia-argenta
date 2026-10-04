-- Eco Pesos: capa de economia sobre PhunMart 2.
--
-- No modifica PhunMart. Registra sus propias definiciones (precios, grupos,
-- pools, tiendas y pagos) en Core.defaultPaths, que es el mecanismo oficial
-- que PhunMart ofrece para extenderse desde otro mod (ver GUIDE_EXTENDING.md).
--
-- Como nuestros modulos se cargan DESPUES de los de PhunMart, cualquier clave
-- que repitamos (por ejemplo `currency_base`) reemplaza a la original.
require "PhunMart/core"

local Core = PhunMart

EcoPesos = EcoPesos or {
    name = "EcoPesos",
    version = "0.1.0"
}

--- Lee una opcion de sandbox propia. Las opciones de otro mod no pasan por
--- Core.getOption, que solo mira el prefijo "PhunMart.".
function EcoPesos.getOption(name, default)
    local vars = SandboxVars and SandboxVars.EcoPesos
    local value = vars and vars[name]
    if value == nil then
        return default
    end
    return value
end

-- Un archivo de `shared` puede ejecutarse dos veces (una por el cargador del
-- juego y otra por un require), asi que cada registro se protege.
local function registerOnce(list, value)
    for _, existing in ipairs(list) do
        if existing == value then
            return
        end
    end
    table.insert(list, value)
end

registerOnce(Core.defaultPaths.prices, "EcoPesos/defaults/prices")
registerOnce(Core.defaultPaths.specials, "EcoPesos/defaults/specials")
registerOnce(Core.defaultPaths.items, "EcoPesos/defaults/items")
registerOnce(Core.defaultPaths.groups, "EcoPesos/defaults/groups")
registerOnce(Core.defaultPaths.pools, "EcoPesos/defaults/pools")
registerOnce(Core.defaultPaths.shops, "EcoPesos/defaults/shops")

return EcoPesos
