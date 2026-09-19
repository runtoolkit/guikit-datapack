# api/open already closes the current menu first (see api/open.mcfunction), so no manual close.
function guikit:internal/clear_in
data merge storage guikit:in {menu:"demo:chest_boat_demo", page:0, timer:600}
function guikit:api/open
ride @s mount @e[type=#guikit:container,tag=guikit.cart,sort=nearest,limit=1,distance=..2.4]
