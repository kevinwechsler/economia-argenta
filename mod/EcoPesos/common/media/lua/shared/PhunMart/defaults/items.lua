-- Precios por item de Eco Pesos.
--
-- Pisan el precio por defecto del grupo. Solo se listan los items que se
-- apartan de su grupo; el resto usa el precio del grupo.
--
-- Ojo: esta tabla es global para PhunMart. Si en el futuro se habilitan las
-- maquinas de PhunMart, estos precios tambien aplican ahi.
local function precio(key)
    return {
        price = key
    }
end

return {
    -- Almacen
    ["TunaTin"] = precio("eco_5"),
    ["CannedCornedBeef"] = precio("eco_5"),
    ["BeefJerky"] = precio("eco_5"),
    ["Chocolate"] = precio("eco_3"),
    ["Whiskey"] = precio("eco_15"),

    -- Ferreteria
    ["Axe"] = precio("eco_40"),
    ["Sledgehammer"] = precio("eco_60"),
    ["Crowbar"] = precio("eco_30"),
    ["Battery"] = precio("eco_5"),
    ["Lighter"] = precio("eco_5"),
    ["Nails"] = precio("eco_1"),
    ["Torch"] = precio("eco_10"),
    ["Antibiotics"] = precio("eco_30"),
    ["SutureNeedle"] = precio("eco_10"),
    ["Splint"] = precio("eco_8"),
    ["Bandage"] = precio("eco_3"),
    ["AlcoholWipes"] = precio("eco_3"),
    ["Bag_ALICEpack"] = precio("eco_100"),
    ["Bag_BigHikingBag"] = precio("eco_60"),
    ["Bag_DuffelBag"] = precio("eco_40"),
    ["Vest_BulletCivilian"] = precio("eco_150"),
    ["Hat_RiotHelmet"] = precio("eco_60"),
    ["Jacket_ArmyCamoGreen"] = precio("eco_60"),
    ["Generator"] = precio("eco_300"),
    ["PetrolCan"] = precio("eco_30"),
    ["Padlock"] = precio("eco_15"),
    ["FishingRod"] = precio("eco_20"),

    -- Armeria
    ["BaseballBat"] = precio("eco_20"),
    ["HuntingKnife"] = precio("eco_20"),
    ["SpearCrafted"] = precio("eco_10"),
    ["Machete"] = precio("eco_80"),
    ["Katana"] = precio("eco_250"),
    ["Pistol"] = precio("eco_200"),
    ["Pistol2"] = precio("eco_250"),
    ["Shotgun"] = precio("eco_300"),
    ["HuntingRifle"] = precio("eco_400"),
    ["Bullets9mmBox"] = precio("eco_40"),
    ["Bullets45Box"] = precio("eco_50"),
    ["Bullets44Box"] = precio("eco_60"),
    ["ShotgunShellsBox"] = precio("eco_50"),
    ["308Box"] = precio("eco_80")
}
