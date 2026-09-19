# macro: $(menu)
# container type comes from the registered menu, default chest_minecart
$data modify storage guikit:ctx ctype set from storage guikit:reg menus."$(menu)".container
execute unless data storage guikit:ctx ctype run data modify storage guikit:ctx ctype set value "chest_minecart"

# "ender_chest" / "barrel" are themed presets, not real entity types -- see internal/summon_themed.
# Anything else is passed straight through to /summon as before (chest_minecart, hopper_minecart, ...).
execute if data storage guikit:ctx {ctype:"ender_chest"} run function guikit:internal/summon_themed {theme:"ender_chest",name:'{"text":"Ender Chest","italic":false}'}
execute if data storage guikit:ctx {ctype:"barrel"} run function guikit:internal/summon_themed {theme:"barrel",name:'{"text":"Barrel","italic":false}'}
execute unless data storage guikit:ctx {ctype:"ender_chest"} unless data storage guikit:ctx {ctype:"barrel"} run function guikit:internal/summon_type with storage guikit:ctx

data remove storage guikit:ctx ctype
