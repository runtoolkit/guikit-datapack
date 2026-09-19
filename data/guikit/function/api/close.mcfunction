# guikit :: api/close        as <player>
# Only touches the cart owned by THIS player (uid match).
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #uid guikit.tmp run function guikit:internal/dispose_cart
clear @s *[custom_data~{guikit:{w:1b}}]
scoreboard players reset @s guikit.timer
scoreboard players reset @s guikit.page
scoreboard players reset @s guikit.dirty
scoreboard players reset @s guikit.uid
function #guikit:clear_tags
