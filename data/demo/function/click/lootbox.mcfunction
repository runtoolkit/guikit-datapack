# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
data modify storage guikit:in {} set value {max:99}
function guikit:widget/roll
execute if score #roll guikit.tmp matches 0..69  run give @s minecraft:dirt 8
execute if score #roll guikit.tmp matches 70..94 run give @s minecraft:iron_ingot 3
execute if score #roll guikit.tmp matches 95..99 run give @s minecraft:diamond 1
data modify storage guikit:in {} set value {msg:"You opened the loot box!", color:"light_purple"}
function guikit:widget/say
