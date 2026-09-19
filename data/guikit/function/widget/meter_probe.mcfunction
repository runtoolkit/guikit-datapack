# guikit :: widget/meter_probe    as player    storage guikit:p {id:"ns:id"}
# ONE registration per meter (not per cell!) in your #guikit:probe listener:
#   data merge storage guikit:p {id:"ns:vol"}
#   function guikit:widget/meter_probe with storage guikit:p
#
# Tests each of the meter's `width` cells in turn; on a hit, sets the def's `obj` to the clicked
# cell's scaled value (cell 0..width-1 -> (cell+1)*max/width, floor) and marks the redraw dirty.
function guikit:internal/clear_mtr
$data modify storage guikit:mtr cur set from storage guikit:mtr defs."$(id)"
execute unless data storage guikit:mtr cur run return 0
data modify storage guikit:mtr obj set from storage guikit:mtr cur.obj
data modify storage guikit:mtr max set from storage guikit:mtr cur.max
execute store result score #mw guikit.tmp run data get storage guikit:mtr cur.width
data modify storage guikit:mtr id set from storage guikit:p id
scoreboard players set #mc guikit.tmp 0
function guikit:internal/meter_probe_loop
