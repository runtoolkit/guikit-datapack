# guikit :: widget/meter_draw    as player   storage guikit:w = {slot, id}
# Call as:
#   data merge storage guikit:w {slot:20, id:"ns:vol"}
#   function guikit:widget/meter_draw with storage guikit:w
#
# `id` must be registered once, in your #guikit:register listener (like widget/button's defs):
#   data modify storage guikit:mtr defs."ns:vol" set value {obj:"volume", width:5, max:5,
#     full:"minecraft:lime_dye", empty:"minecraft:gray_dye", name:{text:"Volume",italic:false}}
#
# Draws `width` clickable cells starting at `slot`, filled up to the live `obj` score (same
# scaling as widget/progress: filled = obj * width / max). Cell i's clickable id is "<id>_i" --
# click it with widget/meter_probe (ONE registration per meter, not per cell).
function guikit:internal/clear_mtr
$data modify storage guikit:mtr cur set from storage guikit:mtr defs."$(id)"
execute unless data storage guikit:mtr cur run return 0
data modify storage guikit:mtr obj set from storage guikit:mtr cur.obj
data modify storage guikit:mtr max set from storage guikit:mtr cur.max
data modify storage guikit:mtr width set from storage guikit:mtr cur.width

function guikit:internal/progress_calc with storage guikit:mtr

data modify storage guikit:pg cur set value 0
data modify storage guikit:pg slot set from storage guikit:w slot
data modify storage guikit:pg width set from storage guikit:mtr cur.width
data modify storage guikit:pg full set from storage guikit:mtr cur.full
data modify storage guikit:pg empty set from storage guikit:mtr cur.empty
data modify storage guikit:pg id set from storage guikit:w id
data modify storage guikit:pg name set from storage guikit:mtr cur.name
function guikit:internal/meter_loop
