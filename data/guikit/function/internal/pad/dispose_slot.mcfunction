# guikit :: internal/pad/dispose_slot     as cart     #ds = slots still to clear
# Same recursion shape as internal/pad/step: clears slot #ds-1, then recurses to 0.
scoreboard players remove #ds guikit.tmp 1
execute store result storage guikit:ctx i int 1 run scoreboard players get #ds guikit.tmp
function guikit:internal/pad/dispose_slot_do with storage guikit:ctx
execute if score #ds guikit.tmp matches 1.. run function guikit:internal/pad/dispose_slot
