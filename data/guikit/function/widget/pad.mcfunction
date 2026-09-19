# guikit :: widget/pad     as player  - fill ALL 27 slots with locked panes; draw widgets AFTER this
# Themed carts (guikit.theme.ender_chest / guikit.theme.barrel, see internal/summon_themed) get
# their own pane color; anything else (plain chest_minecart, hopper_minecart, ...) keeps the
# original gray pad.
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.theme.ender_chest] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/pad_cart_ender_chest
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.theme.barrel] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/pad_cart_barrel
execute as @e[type=#guikit:container,tag=guikit.cart,tag=!guikit.theme.ender_chest,tag=!guikit.theme.barrel] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/pad_cart
