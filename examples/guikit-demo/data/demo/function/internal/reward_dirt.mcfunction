# demo :: reward (70%)   as player
give @s minecraft:dirt 8
function guikit:internal/clear_in
data merge storage guikit:in {msg:"You opened the loot box!", color:"light_purple"}
function guikit:widget/say
