# guikit :: widget/pad     as player  - fill ALL 27 slots with locked panes; draw widgets AFTER this
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/pad_cart
