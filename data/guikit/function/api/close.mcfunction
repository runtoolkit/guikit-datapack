# guikit :: api/close        as <player>
# Only touches the cart owned by THIS player (uid match), and only widget items in the inventory.
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #uid guikit.tmp run function guikit:internal/dispose_cart

function guikit:internal/safe_clear

scoreboard players reset @s guikit.timer
scoreboard players reset @s guikit.page
scoreboard players reset @s guikit.dirty
scoreboard players reset @s guikit.uid
scoreboard players reset @s guikit.click
function #guikit:clear_tags
function guikit:internal/cleanup_player
