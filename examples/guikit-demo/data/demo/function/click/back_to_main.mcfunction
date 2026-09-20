# used by both themed sub-menus' "Back" button -- reopens demo:main on page 2 (where they were opened from)
function guikit:internal/clear/in
tag @s remove guikit.m.demo_chest_boat
data merge storage guikit:in {menu:"demo:main", page:2, timer:1200}
function guikit:api/open
