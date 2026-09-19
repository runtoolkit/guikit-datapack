# guikit :: widget/draw    as player   (cart of this player is resolved by uid)
# storage guikit:w = {slot, item, id, type, name, lore}
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/draw_on_cart with storage guikit:w
