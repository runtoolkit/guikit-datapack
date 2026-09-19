# guikit :: tick_player      as player with an open menu, at player
scoreboard players remove @s guikit.timer 1
execute if score @s guikit.timer matches ..0 run return run function guikit:api/close

# cooldown
execute if score @s guikit.cd matches 1.. run scoreboard players remove @s guikit.cd 1

# own cart follows own player ; none found -> close
scoreboard players operation #uid guikit.tmp = @s guikit.uid
scoreboard players set #found guikit.tmp 0
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #uid guikit.tmp run function guikit:internal/follow
execute if score #found guikit.tmp matches 0 run return run function guikit:api/close

# click detection: a GUI item in the inventory == the player shift-clicked it
execute store result score @s guikit.click run clear @s *[custom_data~{guikit:{w:1b}}] 0
execute if score @s guikit.click matches 1.. run function #guikit:probe
clear @s *[custom_data~{guikit:{w:1b}}]
scoreboard players reset @s guikit.click

# redraw only when a handler asked for it
execute if score @s guikit.dirty matches 1 run function guikit:core/redraw
