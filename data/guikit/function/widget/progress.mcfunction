# guikit :: widget/progress   as player
# storage guikit:w = {obj:"score", slot:9, width:5, max:10, full:"minecraft:lime_stained_glass_pane",
#                     empty:"minecraft:gray_stained_glass_pane", id:"bar1", name:{text:" "}}
# Draws `width` cells starting at `slot`. Cell i (0-based) is full when i < filled.
function guikit:internal/progress/calc with storage guikit:w
# working copy
data modify storage guikit:pg cur set value 0
data modify storage guikit:pg slot set from storage guikit:w slot
data modify storage guikit:pg width set from storage guikit:w width
data modify storage guikit:pg full set from storage guikit:w full
data modify storage guikit:pg empty set from storage guikit:w empty
data modify storage guikit:pg id set from storage guikit:w id
data modify storage guikit:pg name set from storage guikit:w name
function guikit:internal/progress/loop
