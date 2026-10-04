-- Compila las definiciones de Eco Pesos con el compilador real de PhunMart,
-- fuera del juego, usando el harness de tests de PhunMart.
--
-- Uso: luajit tests/test_compile.lua   (desde la raiz del proyecto)
local here = arg[0]:match("^(.*)[/\\][^/\\]*$") or "."
local root = here .. "/.."
local phunTests = root .. "/tests/harness"
local ecoShared = root .. "/mod/EconomiaArgenta/common/media/lua/shared"

package.path = phunTests .. "/?.lua;" .. ecoShared .. "/?.lua;" .. package.path

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
    EconomiaArgenta = {
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
for _, name in ipairs({"PittyTheTool", "FinalAmendment", "PrawnStars"}) do
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
        ok("la escopeta cuesta 36 billetes", amount == 36, tostring(amount) .. " kind=" .. tostring(p and p.kind))
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
    ok("el diamante paga 10 billetes", action and action.type == "adjustBalance" and action.amount == 1000,
        action and tostring(action.amount))
end

print("-- catalogo --")
local function precioDe(pool, item)
    for _, offer in pairs((runtime.pools[pool] or {}).offers or {}) do
        if offer.item == item then
            local p = offer.price
            return p and p.kind, p and (p.items and p.items[1] and p.items[1].amount or p.amount), offer
        end
    end
end
local k, a = precioDe("pool_eco_armeria", "Katana")
ok("la katana cuesta 80 billetes", a == 80, tostring(a))
k, a = precioDe("pool_eco_armeria", "Bullets9mmBox")
ok("una caja de 9mm cuesta 3 billetes", a == 3, tostring(a))
k, a = precioDe("pool_eco_ferreteria", "NailsBox")
ok("una caja de clavos cuesta 1 billete", a == 1, tostring(a))
k, a = precioDe("pool_eco_ferreteria", "Hammer")
ok("la ferreteria no vende herramientas", k == nil)
local kind, amount, offer = precioDe("pool_eco_compro_oro", "Ring_Left_RingFinger_Silver")
ok("la plata se entrega de a 5", kind == "items" or kind == "self", tostring(kind))
ok("cantidad a entregar de plata = 5", amount == 5, tostring(amount))
local action = offer and offer.reward and offer.reward.actions and offer.reward.actions[1]
ok("5 de plata pagan 1 billete", action and action.amount == 100, action and tostring(action.amount))
ok("no hay almacen", runtime.shops["GoodPhoods"] == nil)

print("-- retos individuales --")
SandboxVars.EconomiaArgenta.RecompensasKills = true
package.loaded["PhunMart/defaults/token_rewards"] = nil
local retos = require "PhunMart/defaults/token_rewards"
ok("hay retos de zombies", retos.zombieKills and #retos.zombieKills > 0)
ok("sin retos de corredores", retos.sprinterKills == nil)
local todosPesos = true
for _, lista in ipairs({retos.zombieKills or {}, retos.sprinterKills or {}}) do
    for _, r in ipairs(lista) do
        local premio = r.rewards and r.rewards[1]
        if not (premio and premio.item == "Base.Money" and (premio.amount or 0) > 0 and (r.kills or r.everyKills)) then
            todosPesos = false
        end
    end
end
ok("todos los retos pagan billetes", todosPesos)
SandboxVars.EconomiaArgenta.RecompensasKills = false
package.loaded["PhunMart/defaults/token_rewards"] = nil
local apagados = require "PhunMart/defaults/token_rewards"
local cantidad = 0
for _ in pairs(apagados) do
    cantidad = cantidad + 1
end
ok("apagados no hay retos", cantidad == 0)

print("")
print(string.format("%d passed, %d failed", passed, failed))
os.exit(failed == 0 and 0 or 1)
