# guikit :: api/close        as <player>
# Only touches the cart owned by THIS player (uid match), and only widget items in the inventory.
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute store result storage guikit:ctx uid int 1 run scoreboard players get @s guikit.uid
function guikit:internal/summon/unbind with storage guikit:ctx
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.uid = #uid guikit.tmp run function guikit:internal/pad/dispose_cart

function guikit:internal/safe_clear

scoreboard players reset @s guikit.timer
scoreboard players reset @s guikit.tmax
scoreboard players reset @s guikit.page
scoreboard players reset @s guikit.dirty
scoreboard players reset @s guikit.uid
scoreboard players reset @s guikit.slots
scoreboard players reset @s guikit.click
function #guikit:clear_tags
function guikit:internal/clear/player

# hook: menu packs can clean up their own state here. Runs AFTER the cart is gone and this
# player's guikit scores are reset, so a listener must NOT call guikit:api/open / refresh from
# here expecting the old menu to exist. Same trust model as #guikit:clear_tags.
function #guikit:on_close
