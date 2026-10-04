-- Compila las definiciones de Eco Pesos con el compilador real de PhunMart,
-- fuera del juego, usando el harness de tests de PhunMart.
--
-- Uso: luajit tests/test_compile.lua   (desde la raiz del proyecto)
local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = here .. "/.."
local phun = root .. "/ref/PhunMart"
local phunTests = phun .. "/Tests/lua"
local phunShared = phun .. "/Contents/mods/PhunMart2/common/media/lua/shared"
local ecoShared = root .. "/mod/EcoPesos/common/media/lua/shared"

package.path = phunTests .. "/?.lua;" .. phunShared .. "/?.lua;" .. ecoShared .. "/?.lua;" .. package.path

local harness = require "harness"
harness.installGlobals()

-- Lo mismo que test_extension_points.lua: los globals del motor que tocan
-- core.lua y compiler.lua al cargar y al compilar.
_G.getScriptManager = function()
    return {
        getVehicle = function()
            return nil
        end,
        FindItem = function()
            return nil
        end,
        getAllItems = function()
            return {
                size = function()
                    return 0
                end,
                get = function()
                    return nil
                end
            }
        end
    }
end
_G.getActivatedMods = function()
    return {
        size = function()
            return 0
        end,
        get = function()
            return nil
        end
    }
end
_G.SandboxVars = {
    PhunMart = {
        Debug = false
    },
    EcoPesos = {
        FactorPrecios = 100,
        FactorCompraOro = 100,
        RecompensasKills = false
    }
}
_G.LuaEventManager = {
    AddEvent = function()
    end
}
_G.getSandboxOptions = function()
    return {
        getOptionByName = function()
            return nil
        end
    }
end
_G.ModData = {
    getOrCreate = function()
        return {}
    end
}
_G.triggerEvent = function()
end

require "PhunMart/core"
require "PhunMart/compiler"
require "EcoPesos/init"
local Core = PhunMart

harness.strip()

---------------------------------------------------------------------------

local passed, failed = 0, 0
local function ok(label, condition, detail)
    if condition then
        passed = passed + 1
        print("  ok    " .. label)
    else
        failed = failed + 1
        print("  FAIL  " .. label .. (detail and ("  <- " .. tostring(detail)) or ""))
    end
end

print("-- registro en defaultPaths --")
local function has(list, v)
    for _, x in ipairs(list) do
        if x == v then
            return true
        end
    end
    return false
end
ok("prices registrado", has(Core.defaultPaths.prices, "EcoPesos/defaults/prices"))
ok("shops registrado", has(Core.defaultPaths.shops, "EcoPesos/defaults/shops"))
ok("items registrado", has(Core.defaultPaths.items, "EcoPesos/defaults/items"))

print("-- compilacion completa --")
local runtime, log = Core.compileWith({})
ok("compila sin errores", #(log.errors or {}) == 0, table.concat(log.errors or {}, " | "))
for _, e in ipairs(log.errors or {}) do
    print("    ERROR: " .. tostring(e))
end
local ecoWarnings = {}
for _, w in ipairs(log.warnings or {}) do
    if tostring(w):lower():find("eco") then
        table.insert(ecoWarnings, w)
    end
end
print("    warnings totales: " .. #(log.warnings or {}) .. ", relacionados a Eco: " .. #ecoWarnings)
for _, w in ipairs(ecoWarnings) do
    print("    WARN: " .. tostring(w))
end

print("-- moneda --")
local cur = Core.currencyDef()
ok("currency_base es un item", cur.kind == "items", cur.kind)
ok("el item es Base.Money", cur.item == "Base.Money", tostring(cur.item))
ok("factor 0.01 con FactorPrecios=100", math.abs((cur.factor or 0) - 0.01) < 1e-9, tostring(cur.factor))
local amt, item = Core.currencyValueOf(1500)
ok("un pago de 1500 centavos son 15 billetes", amt == 15 and item == "Base.Money", tostring(amt) .. " " .. tostring(item))

print("-- tiendas --")
for _, name in ipairs({"EcoAlmacen", "EcoFerreteria", "EcoArmeria", "EcoComproOro"}) do
    local shop = runtime.shops[name]
    ok(name .. " existe en runtime", shop ~= nil)
    if shop then
        ok(name .. " no se coloca al azar", (shop.probability or 0) == 0, tostring(shop.probability))
    end
end

print("-- pools y precios --")
local pool = runtime.pools and runtime.pools["pool_eco_armeria"]
ok("pool_eco_armeria existe", pool ~= nil)
if pool then
    ok("pool_eco_armeria es sticky", pool.sticky == true)
    local n, sample = 0, nil
    for id, offer in pairs(pool.offers or {}) do
        n = n + 1
        if offer.item == "Shotgun" then
            sample = offer
        end
    end
    ok("pool_eco_armeria tiene ofertas", n > 0, tostring(n))
    if sample then
        local p = sample.price
        local amount = p and p.items and p.items[1] and p.items[1].amount
        ok("la escopeta cuesta 300 billetes", amount == 300, tostring(amount) .. " kind=" .. tostring(p and p.kind))
    else
        ok("hay una oferta de escopeta", false, "no se encontro Shotgun")
    end
end

local oro = runtime.pools and runtime.pools["pool_eco_compro_oro"]
ok("pool_eco_compro_oro existe", oro ~= nil)
if oro then
    local sample
    for id, offer in pairs(oro.offers or {}) do
        if offer.item == "Diamond" then
            sample = offer
        end
    end
    ok("el diamante se entrega (self)", sample and sample.price and sample.price.kind == "self",
        sample and sample.price and sample.price.kind)
    local reward = sample and sample.reward
    local action = reward and reward.actions and reward.actions[1]
    ok("el diamante paga 150 pesos", action and action.type == "adjustBalance" and action.amount == 15000,
        action and tostring(action.amount))
end

print("")
print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
