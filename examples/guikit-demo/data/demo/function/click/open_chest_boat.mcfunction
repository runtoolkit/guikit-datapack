# api/open already closes the current menu first (see api/open.mcfunction), so no manual close.
function guikit:internal/clear/in
data merge storage guikit:in {menu:"demo:chest_boat_demo", page:0, timer:600}
function guikit:api/open
# mount THIS player's cart only (matching uid), not merely the nearest one -- another player's boat may be closer
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart,distance=..3] if score @s guikit.uid = #uid guikit.tmp run tag @s add demo.mount
ride @s mount @e[type=#guikit:container,tag=demo.mount,limit=1]
tag @e[tag=demo.mount] remove demo.mount
