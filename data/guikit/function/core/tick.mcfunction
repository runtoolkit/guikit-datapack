# guikit :: tick
execute as @a[scores={guikit.timer=1..}] at @s run function guikit:core/tick_player
kill @e[type=minecraft:item,nbt={Item:{components:{"minecraft:custom_data":{guikit:{w:1b}}}}}]
