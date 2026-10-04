-- Grupos de items de Eco Pesos.
--
-- Un grupo junta items con un precio por defecto. Los precios por item que
-- difieren del grupo viven en defaults/items.lua, que tiene prioridad.
-- Todos los items son vanilla de Build 42 (verificados contra media/scripts).
return {

    -- =========================================================
    -- Almacen: comida y bebida
    -- =========================================================
    eco_conservas = {
        label = "Conservas",
        defaults = {
            price = "eco_3",
            offer = {
                weight = 1.0
            }
        },
        items = {"TinnedBeans", "TunaTin", "CannedCornedBeef", "CannedTomato", "CannedCarrots", "CannedPeas",
                 "CannedPotato2"}
    },

    eco_secos = {
        label = "Secos y snacks",
        defaults = {
            price = "eco_2",
            offer = {
                weight = 1.0
            }
        },
        items = {"Rice", "Pasta", "Cereal", "PeanutButter", "BeefJerky", "Crisps", "Chocolate"}
    },

    eco_vicios = {
        label = "Vicios",
        defaults = {
            price = "eco_8",
            offer = {
                weight = 1.0
            }
        },
        items = {"Whiskey", "CigarettePack"}
    },

    -- =========================================================
    -- Ferreteria: herramientas, equipo y botiquin
    -- =========================================================
    eco_herramientas = {
        label = "Herramientas",
        defaults = {
            price = "eco_20",
            offer = {
                weight = 1.0
            }
        },
        items = {"Hammer", "Saw", "Crowbar", "Axe", "Sledgehammer", "Shovel", "Torch", "Battery", "Lighter", "Nails"}
    },

    eco_botiquin = {
        label = "Botiquin",
        defaults = {
            price = "eco_5",
            offer = {
                weight = 1.0
            }
        },
        items = {"Bandage", "AlcoholWipes", "Antibiotics", "Pills", "SutureNeedle", "Splint"}
    },

    eco_equipo = {
        label = "Equipo",
        defaults = {
            price = "eco_30",
            offer = {
                weight = 1.0
            }
        },
        items = {"Bag_NormalHikingBag", "Bag_BigHikingBag", "Bag_DuffelBag", "Bag_ALICEpack", "Shoes_ArmyBoots",
                 "Gloves_LeatherGloves", "Hat_BicycleHelmet", "Hat_RiotHelmet", "Vest_BulletCivilian",
                 "Jacket_ArmyCamoGreen"}
    },

    eco_varios = {
        label = "Varios",
        defaults = {
            price = "eco_40",
            offer = {
                weight = 1.0
            }
        },
        items = {"Generator", "PetrolCan", "Padlock", "WalkieTalkie4", "FishingRod"}
    },

    -- =========================================================
    -- Armeria
    -- =========================================================
    eco_blancas = {
        label = "Armas blancas",
        defaults = {
            price = "eco_40",
            offer = {
                weight = 1.0
            }
        },
        items = {"BaseballBat", "HuntingKnife", "SpearCrafted", "Machete", "Katana"}
    },

    eco_fuego = {
        label = "Armas de fuego",
        defaults = {
            price = "eco_200",
            offer = {
                weight = 1.0
            }
        },
        items = {"Pistol", "Pistol2", "Shotgun", "HuntingRifle"}
    },

    eco_municion = {
        label = "Municion",
        defaults = {
            price = "eco_40",
            offer = {
                weight = 1.0
            }
        },
        items = {"Bullets9mmBox", "Bullets45Box", "Bullets44Box", "ShotgunShellsBox", "308Box"}
    },

    -- =========================================================
    -- Compro Oro: el jugador entrega la joya y recibe billetes
    -- =========================================================
    eco_joyas_plata = {
        label = "Plata",
        defaults = {
            price = "eco_entrega_1",
            reward = "eco_pago_plata",
            offer = {
                weight = 1.0
            }
        },
        items = {"Bracelet_BangleLeftSilver", "Bracelet_BangleRightSilver", "Bracelet_ChainLeftSilver",
                 "Bracelet_ChainRightSilver", "Necklace_Silver", "NecklaceLong_Silver", "Earring_Stud_Silver",
                 "Earring_LoopLrg_Silver", "Ring_Right_RingFinger_Silver", "Ring_Left_RingFinger_Silver",
                 "SilverScrap", "SilverCoin"}
    },

    eco_joyas_oro = {
        label = "Oro",
        defaults = {
            price = "eco_entrega_1",
            reward = "eco_pago_oro",
            offer = {
                weight = 1.0
            }
        },
        items = {"Bracelet_BangleLeftGold", "Bracelet_BangleRightGold", "Bracelet_ChainLeftGold",
                 "Bracelet_ChainRightGold", "Necklace_Gold", "NecklaceLong_Gold", "Earring_Stud_Gold",
                 "Earring_LoopLrg_Gold", "Ring_Right_RingFinger_Gold", "Ring_Left_RingFinger_Gold",
                 "Ring_Right_MiddleFinger_Gold", "Ring_Left_MiddleFinger_Gold", "GoldScrap", "GoldCoin", "Locket"}
    },

    eco_relojes = {
        label = "Relojes",
        defaults = {
            price = "eco_entrega_1",
            reward = "eco_pago_relojes",
            offer = {
                weight = 1.0
            }
        },
        items = {"Pocketwatch"}
    },

    eco_piedras = {
        label = "Piedras preciosas",
        defaults = {
            price = "eco_entrega_1",
            reward = "eco_pago_piedras",
            offer = {
                weight = 1.0
            }
        },
        items = {"Amethyst", "Ruby", "Sapphire", "Emerald", "Necklace_GoldRuby", "Necklace_SilverSapphire",
                 "Necklace_GoldDiamond", "Necklace_SilverDiamond", "Ring_Right_RingFinger_GoldDiamond",
                 "Ring_Left_RingFinger_GoldDiamond", "Ring_Right_RingFinger_SilverDiamond",
                 "Ring_Left_RingFinger_SilverDiamond"}
    },

    eco_lingotes = {
        label = "Lingotes",
        defaults = {
            price = "eco_entrega_1",
            reward = "eco_pago_lingote",
            offer = {
                weight = 1.0
            }
        },
        items = {"GoldBar", "SmallGoldBar"}
    },

    eco_diamantes = {
        label = "Diamantes",
        defaults = {
            price = "eco_entrega_1",
            reward = "eco_pago_diamante",
            offer = {
                weight = 1.0
            }
        },
        items = {"Diamond"}
    }
}
