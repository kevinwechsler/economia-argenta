-- Catalogo de Economia Argenta: QUE vende cada tienda y A CUANTO.
--
-- Es el unico lugar donde se tocan precios. groups.lua e items.lua se arman
-- a partir de esta tabla. Los precios estan en billetes (Base.Money).
--
-- Escala de referencia (server intermedio, poca plata en el mundo):
--   una caja registradora da ~1 billete, un banco unos pocos mas.
--   5 billetes  = una caja de balas
--   15 billetes = una pistola
--   100+        = un rifle de asalto (meta de largo plazo)
--
-- Los nombres de items van sin "Base." (asi los indexa el motor). Todos son
-- items vanilla de Build 42.
local M = {}

-- =========================================================
-- Armeria
-- =========================================================
M.armeria = {{
    key = "eco_pistolas",
    label = "Pistolas y revolveres",
    items = {
        Revolver_Short = 12, -- .38
        Pistol = 14, -- 9mm
        Revolver = 16, -- .357
        Pistol2 = 18, -- .45
        Pistol3 = 22, -- .44
        Revolver_Long = 22 -- .44
    }
}, {
    key = "eco_escopetas",
    label = "Escopetas",
    items = {
        ShotgunSawnoff = 20,
        DoubleBarrelShotgunSawnoff = 22,
        DoubleBarrelShotgun = 28,
        Shotgun = 36,
        JS3T_Shotgun = 44
    }
}, {
    key = "eco_rifles",
    label = "Rifles",
    items = {
        VarmintRifle = 36,
        L92_Carbine = 40,
        TrapperCarbine = 40,
        L94_Rifle = 44,
        HuntingRifle = 56,
        MSR7T_Rifle = 64
    }
}, {
    key = "eco_asalto",
    label = "Rifles de asalto",
    items = {
        AssaultRifle = 100,
        JS14_Rifle = 110,
        AssaultRifle2 = 120
    }
}, {
    key = "eco_municion",
    label = "Municion",
    items = {
        Bullets38Box = 3,
        Bullets9mmBox = 3,
        Bullets45Box = 4,
        Bullets357Box = 4,
        ShotgunShellsBox = 4,
        Bullets44Box = 5,
        ["3030Box"] = 6,
        ["556Box"] = 6,
        ["308Box"] = 7
    }
}, {
    key = "eco_cargadores",
    label = "Cargadores",
    items = {
        ["9mmClip"] = 3,
        ["45Clip"] = 3,
        ["44Clip"] = 4,
        ["556Clip"] = 5,
        M14Clip = 6,
        JS14_Clip = 6
    }
}, {
    key = "eco_accesorios",
    label = "Accesorios",
    items = {
        AmmoStraps = 4,
        RecoilPad = 4,
        ChokeTubeFull = 6,
        ChokeTubeImproved = 6,
        GunLight = 6,
        Laser = 8,
        TritiumSights = 10,
        x2Scope = 10,
        RedDot = 12,
        x4Scope = 16,
        x8Scope = 24
    }
}, {
    key = "eco_blancas",
    label = "Armas blancas",
    items = {
        BaseballBat = 10,
        HuntingKnife = 6,
        Machete = 25,
        Katana = 80
    }
}}

-- =========================================================
-- Ferreteria: consumibles chicos que se gastan construyendo y reparando.
-- Sin herramientas, bolsos, ropa ni botiquin: eso se encuentra.
-- =========================================================
M.ferreteria = {{
    key = "eco_fijaciones",
    label = "Clavos, tornillos y pegamentos",
    items = {
        NailsBox = 1,
        ScrewsBox = 1,
        DuctTape = 1,
        Scotchtape = 1,
        Glue = 1,
        Woodglue = 1,
        Epoxy = 2
    }
}, {
    key = "eco_cables",
    label = "Cables, sogas e hilos",
    items = {
        Thread = 1,
        Twine = 1,
        Rope = 2,
        Wire = 2,
        ElectricWire = 2,
        BarbedWire = 3
    }
}, {
    key = "eco_electricidad",
    label = "Electricidad y luz",
    items = {
        Battery = 1,
        LightBulb = 1,
        Candle = 1,
        Matchbox = 1,
        Lighter = 1,
        ElectronicsScrap = 2
    }
}, {
    key = "eco_soldadura",
    label = "Soldadura y gas",
    items = {
        WeldingRods = 2,
        PropaneTank = 5
    }
}, {
    key = "eco_limpieza",
    label = "Alcohol y limpieza",
    items = {
        AlcoholWipes = 1,
        Disinfectant = 1,
        Bleach = 1
    }
}}

-- =========================================================
-- Compro Oro: el jugador ENTREGA el item y recibe billetes.
-- `entrega` = cuantas unidades hay que dar, `pago` = billetes que recibe.
-- Las joyas abundan en los zombies, por eso las comunes pagan poco.
--
-- Un elemento entre llaves {...} es UNA fila con variantes: se muestra el
-- primero y se acepta cualquiera de ellos como pago (anillo izquierdo o
-- derecho, dedo anular o mayor, etc., que el juego llama igual).
-- =========================================================
M.compro_oro = {{
    key = "eco_oro_plata",
    label = "Plata (5 por 1 billete)",
    entrega = 5,
    pago = 1,
    items = {{"Bracelet_BangleLeftSilver", "Bracelet_BangleRightSilver", "Bracelet_ChainLeftSilver",
              "Bracelet_ChainRightSilver"}, {"Ring_Right_RingFinger_Silver", "Ring_Left_RingFinger_Silver",
                                             "Ring_Right_MiddleFinger_Silver", "Ring_Left_MiddleFinger_Silver"},
             "Necklace_Silver", "NecklaceLong_Silver", "Necklace_SilverCrucifix", "Earring_Stud_Silver",
             "Earring_LoopLrg_Silver", "Earring_LoopMed_Silver", "SilverScrap", "SilverCoin"}
}, {
    key = "eco_oro_oro",
    label = "Oro (2 por 1 billete)",
    entrega = 2,
    pago = 1,
    items = {{"Bracelet_BangleLeftGold", "Bracelet_BangleRightGold", "Bracelet_ChainLeftGold",
              "Bracelet_ChainRightGold"}, {"Ring_Right_RingFinger_Gold", "Ring_Left_RingFinger_Gold",
                                           "Ring_Right_MiddleFinger_Gold", "Ring_Left_MiddleFinger_Gold"},
             "Necklace_Gold", "NecklaceLong_Gold", "Earring_Stud_Gold", "Earring_LoopLrg_Gold", "Earring_LoopMed_Gold",
             "GoldScrap", "Locket"}
}, {
    key = "eco_oro_monedas",
    label = "Monedas de oro y relojes",
    entrega = 1,
    pago = 1,
    items = {"GoldCoin", "Pocketwatch"}
}, {
    key = "eco_oro_piedras",
    label = "Piedras preciosas",
    entrega = 1,
    pago = 2,
    items = {"Amethyst", "Ruby", "Sapphire", "Emerald", "Necklace_GoldRuby", "Necklace_SilverSapphire",
             "Necklace_GoldDiamond", "Necklace_SilverDiamond",
             {"Ring_Right_RingFinger_GoldDiamond", "Ring_Left_RingFinger_GoldDiamond",
              "Ring_Right_MiddleFinger_GoldDiamond", "Ring_Left_MiddleFinger_GoldDiamond"},
             {"Ring_Right_RingFinger_SilverDiamond", "Ring_Left_RingFinger_SilverDiamond",
              "Ring_Right_MiddleFinger_SilverDiamond", "Ring_Left_MiddleFinger_SilverDiamond"},
             {"Ring_Right_RingFinger_GoldRuby", "Ring_Left_RingFinger_GoldRuby", "Ring_Right_MiddleFinger_GoldRuby",
              "Ring_Left_MiddleFinger_GoldRuby"}}
}, {
    key = "eco_oro_lingote_chico",
    label = "Lingote chico",
    entrega = 1,
    pago = 6,
    items = {"SmallGoldBar"}
}, {
    key = "eco_oro_diamante",
    label = "Diamante",
    entrega = 1,
    pago = 10,
    items = {"Diamond"}
}, {
    key = "eco_oro_lingote",
    label = "Lingote",
    entrega = 1,
    pago = 20,
    items = {"GoldBar"}
}}

return M
