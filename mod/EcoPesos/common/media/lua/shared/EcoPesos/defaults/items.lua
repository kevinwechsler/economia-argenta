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
    ["Base.TunaTin"] = precio("eco_5"),
    ["Base.CannedCornedBeef"] = precio("eco_5"),
    ["Base.BeefJerky"] = precio("eco_5"),
    ["Base.Chocolate"] = precio("eco_3"),
    ["Base.Whiskey"] = precio("eco_15"),

    -- Ferreteria
    ["Base.Axe"] = precio("eco_40"),
    ["Base.Sledgehammer"] = precio("eco_60"),
    ["Base.Crowbar"] = precio("eco_30"),
    ["Base.Battery"] = precio("eco_5"),
    ["Base.Lighter"] = precio("eco_5"),
    ["Base.Nails"] = precio("eco_1"),
    ["Base.Torch"] = precio("eco_10"),
    ["Base.Antibiotics"] = precio("eco_30"),
    ["Base.SutureNeedle"] = precio("eco_10"),
    ["Base.Splint"] = precio("eco_8"),
    ["Base.Bandage"] = precio("eco_3"),
    ["Base.AlcoholWipes"] = precio("eco_3"),
    ["Base.Bag_ALICEpack"] = precio("eco_100"),
    ["Base.Bag_BigHikingBag"] = precio("eco_60"),
    ["Base.Bag_DuffelBag"] = precio("eco_40"),
    ["Base.Vest_BulletCivilian"] = precio("eco_150"),
    ["Base.Hat_RiotHelmet"] = precio("eco_60"),
    ["Base.Jacket_ArmyCamoGreen"] = precio("eco_60"),
    ["Base.Generator"] = precio("eco_300"),
    ["Base.PetrolCan"] = precio("eco_30"),
    ["Base.Padlock"] = precio("eco_15"),
    ["Base.FishingRod"] = precio("eco_20"),

    -- Armeria
    ["Base.BaseballBat"] = precio("eco_20"),
    ["Base.HuntingKnife"] = precio("eco_20"),
    ["Base.SpearCrafted"] = precio("eco_10"),
    ["Base.Machete"] = precio("eco_80"),
    ["Base.Katana"] = precio("eco_250"),
    ["Base.Pistol"] = precio("eco_200"),
    ["Base.Pistol2"] = precio("eco_250"),
    ["Base.Shotgun"] = precio("eco_300"),
    ["Base.HuntingRifle"] = precio("eco_400"),
    ["Base.Bullets9mmBox"] = precio("eco_40"),
    ["Base.Bullets45Box"] = precio("eco_50"),
    ["Base.Bullets44Box"] = precio("eco_60"),
    ["Base.ShotgunShellsBox"] = precio("eco_50"),
    ["Base.308Box"] = precio("eco_80")
}
