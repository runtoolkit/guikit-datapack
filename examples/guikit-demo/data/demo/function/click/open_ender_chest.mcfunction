# api/open already closes the current menu first (see api/open.mcfunction), so no manual close.
function guikit:internal/clear/in
data merge storage guikit:in {menu:"demo:ender_chest_demo", page:0, timer:600}
function guikit:api/open
