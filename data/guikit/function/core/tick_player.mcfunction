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

# click detection: a GUI item in the inventory == the player left-clicked it.
# `clear ... 0` only COUNTS. Everything below is gated on that count, so a tick with no
# GUI item in the inventory never reaches a destructive clear.
scoreboard players set @s guikit.click 0
execute store result score @s guikit.click run clear @s *[custom_data~{guikit:{w:1b}}] 0
execute if score @s guikit.click matches 1.. run function guikit:internal/click_handle

# drop detection: a GUI item in the inventory == the player dropped it.
# same counting trick as click. Kept in its own branch so click_handle can tell
# which event fired (guikit.click vs guikit.drop), instead of both landing here
# indistinguishably.
execute if score @s guikit.drop matches 1.. run function guikit:internal/click_handle
execute if score @s guikit.drop matches 1.. run scoreboard players set @s guikit.drop 0

# redraw when a click happened or a handler asked for it
execute if score @s guikit.dirty matches 1 run function guikit:core/redraw
execute if score @s guikit.dirty matches 1 run scoreboard players set @s guikit.dirty 0
scoreboard players reset @s guikit.click
