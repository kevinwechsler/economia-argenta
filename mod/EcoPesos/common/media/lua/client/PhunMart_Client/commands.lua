if isServer() then
    return
end

local Core = PhunMart
local Toast = require "PhunMart_Client/ui/toast"

local Commands = {}

Commands[Core.commands.openError] = function(args)
    -- Signal the open_shop timed action (if still waiting) to abort early.
    if args.key then
        Core.pendingShopData = Core.pendingShopData or {}
        Core.pendingShopData[args.key] = {
            error = args.message
        }
    end
    local rawMsg = args.message or "Error"
    local message = getTextOrNull("IGUI_PhunMart.Error." .. rawMsg) or rawMsg
    local w = 300
    local h = 150
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil)
    modal:initialise()
    modal:addToUIManager()
end

Commands[Core.commands.serverPurchaseFailed] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    local name = player:getUsername()
    local w = 300
    local h = 150
    local message = getTextOrNull("IGUI_PhunMart.Error." .. arguments.message) or arguments.message
    local modal = ISModalDialog:new(getCore():getScreenWidth() / 2 - w / 2, getCore():getScreenHeight() / 2 - h / 2, w,
        h, message, false, nil, nil, nil);
    modal:initialise()
    modal:addToUIManager()

end

Commands[Core.commands.updateHistory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    Core.players[player:getUsername()] = arguments.history
end

Commands[Core.commands.buy] = function(arguments)
    -- Item-based currency is removed server-side; sendRemoveItemFromContainer
    -- already synced the inventory before this confirmation arrives.
    -- Fire event so the open shop window can update stock and buy button
    triggerEvent(Core.events.OnPurchaseComplete, arguments)
end

Commands[Core.commands.payWithInventory] = function(arguments)
    local player = getSpecificPlayer(arguments.playerIndex)
    for _, v in ipairs(arguments.items) do
        local item = getScriptManager():getItem(v.name)
        for i = 1, v.value do
            local inv = player:getInventory()
            local target = inv:getItemFromTypeRecurse(v.name)
            local container = target:getContainer()
            container:Remove(target)
            sendRemoveItemFromContainer(container, target)
        end
    end
    ISInventoryPage.dirtyUI()
end

Commands[Core.commands.onShopChange] = function(args)
    triggerEvent(Core.events.OnShopChange, args.key, args.data, args.replaced == true)
end

-- The IsMoveAble value each shop sprite shipped with, captured before we first
-- touch it, so a shop that becomes moveable gets back exactly what its tile
-- had. false means the tile was never moveable and is left alone.
local originalMoveable = {}

-- Hides the Pick Up option on machines players may not move. Sprite properties
-- are shared by every machine wearing that sprite, which is fine because a
-- sprite belongs to one shop. The rule itself is enforced in nodestroy.lua;
-- this only keeps the menu honest. Re-run whenever defs change, since a shop
-- can be switched either way while the game is running.
local function ConfigTiles()
    local admin = Core.utils.isAdmin(getSpecificPlayer(0))
    for tileName, shopKey in pairs(Core.spriteToShop) do
        local tile = IsoSpriteManager.instance:getSprite(tileName)
        local props = tile and tile:getProperties()
        if props then
            if originalMoveable[tileName] == nil then
                originalMoveable[tileName] = props:has("IsMoveAble") and (props:get("IsMoveAble") or "") or false
            end
            local original = originalMoveable[tileName]
            if original and (admin or Core.isShopMoveable(shopKey)) then
                props:set("IsMoveAble", original)
            elseif original then
                props:unset("IsMoveAble")
            end
        end
    end
end

Events[Core.events.OnDefsUpdated].Add(ConfigTiles)

Commands[Core.commands.syncPurchases] = function(arguments)
    Core.debug("syncPurchases", arguments)

    Core.purchases.histories = Core.purchases.histories or {}
    Core.purchases.histories[arguments.username] = arguments.history
    ConfigTiles()
end

Commands[Core.commands.requestShop] = function(arguments)
    -- Store data for the open_shop timed action to pick up.
    -- The action polls Core.pendingShopData[key] in its update() loop and
    -- opens the UI once both the animation has finished and this data exists.
    Core.pendingShopData = Core.pendingShopData or {}
    Core.pendingShopData[arguments.key] = arguments.data
end

Commands[Core.commands.getShopList] = function(args)
    -- Shop list is now built from Core.runtime.shops compiled locally.
    -- This handler is kept for compatibility but the round-trip is no longer initiated.
    local player = Core.utils.getPlayerByUsername(args.username)
    if player then
        Core.ClientSystem.instance:openShopList(player)
    end
end

Commands[Core.commands.getInstanceList] = function(args)
    local player = Core.utils.getPlayerByUsername(args.username)
    if player then
        Core.ui.shop_instances.setData(player, args.data)
        Core.ui.shop_selector.updateInstanceCounts(args.data)
    end
end

Commands[Core.commands.requestShopDefs] = function(arguments)
    Core.compileWith(arguments.overrides)
end

Commands[Core.commands.requestItemDefs] = function(arguments)

    Core.debugLn("requestItemDefs: receiving chunk " .. arguments.row .. " of " .. arguments.totalRows)

    if arguments.firstSend then
        Core.defs.items = arguments.items
    else
        for k, v in pairs(arguments.items) do
            Core.defs.items[k] = v
        end
    end

    if arguments.completed then
        triggerEvent(Core.events.OnShopItemDefsReloaded, Core.defs.items)
        Core.debugLn("requestItemDefs: received all " .. arguments.totalRows .. " defs")
    end
end

Commands[Core.commands.requestLocations] = function(args)
    triggerEvent(Core.events.OnShopLocationsReceived, args.locations)
end

-- ---------------------------------------------------------------------------
-- Token reward grant (playtime / kill milestone)
-- ---------------------------------------------------------------------------

-- Shared handler for both MP (server command) and SP (triggered event) paths.
--- Texto del aviso de un reto de Eco Pesos, en el idioma del jugador.
local function retoText(args)
    local reto = args.reto
    if type(reto) ~= "table" or not reto.kills then
        return nil
    end
    local que = getText(reto.kind == "sprinter" and "IGUI_EcoPesos_Reto_Corredores" or "IGUI_EcoPesos_Reto_Zombies")
    local premio = args.item == "Base.Money" and getText("IGUI_EcoPesos_Reto_Pesos", tostring(args.amount or 0)) or
                       (tostring(args.amount or 1) .. "x " .. tostring(args.item))
    return getText("IGUI_EcoPesos_Reto_Cumplido", tostring(reto.kills), que, premio)
end

local function handleGrant(args)
    -- Show toast notification.
    Toast.show({
        text = retoText(args) or args.message or "Reward!"
    })
end

-- MP path: server sends this command after crediting the reward.
Commands[Core.commands.grantReward] = function(args)
    handleGrant(args)
end

-- SP path: server fires the event directly (same Lua state, no network hop).
Events[Core.events.OnRewardGranted].Add(function(args)
    if not args then
        return
    end
    handleGrant(args)
end)

Commands[Core.commands.requestPool] = function(args)
    local player = Core.utils.getPlayerByUsername(args.username)
    if player then
        -- A refresh follows an edit made inside the viewer, so it updates the
        -- open window rather than replacing it and losing the scroll position.
        if args.refresh then
            Core.ui.client.poolViewer.refreshData(args.poolKey, args.data)
        else
            Core.ui.client.poolViewer.open(player, args.poolKey, args.data)
        end
    end
end

return Commands
