# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200
data modify storage guikit:in {} set value {obj:"demo.sound_on"}
function guikit:widget/toggle
execute if score @s demo.sound_on matches 1 run playsound minecraft:block.note_block.pling master @s ~ ~ ~ 1 1
