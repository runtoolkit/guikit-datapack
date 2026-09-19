# guikit :: internal/sweep_keep   as player with an open menu
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.orphan] if score @s guikit.uid = #uid guikit.tmp run tag @s remove guikit.orphan
