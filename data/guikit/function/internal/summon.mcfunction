# macro: $(menu)
# container type comes from the registered menu, default chest_minecart
$data modify storage guikit:ctx ctype set from storage guikit:reg menus."$(menu)".container
execute unless data storage guikit:ctx ctype run data modify storage guikit:ctx ctype set value "chest_minecart"
function guikit:internal/summon_type with storage guikit:ctx
data remove storage guikit:ctx ctype
