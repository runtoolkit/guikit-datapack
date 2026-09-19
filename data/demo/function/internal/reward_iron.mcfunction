# demo :: reward (25%)   as player
give @s minecraft:iron_ingot 3
function guikit:internal/clear_in
data merge storage guikit:in {msg:"You opened the loot box!", color:"light_purple"}
function guikit:widget/say
