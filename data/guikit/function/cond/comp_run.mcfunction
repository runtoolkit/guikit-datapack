# guikit :: cond/comp_run     as player     #cmode 0 = all / 1 = any, #cacc = starting value
# Walks the list guikit:cond of, loading each element into guikit:cond and running cond/check on it.
# One level only: an element that is itself all/any is not evaluated and counts as FAILED. A missing
# `of` fails (return 0, `not` is not applied). Result in #cond guikit.tmp, also returned.
execute store success score #cnot guikit.tmp if data storage guikit:cond {not:1b}
data remove storage guikit:cnd items
data modify storage guikit:cnd items set from storage guikit:cond of
execute unless data storage guikit:cnd items run return 0
execute store result score #cn guikit.tmp run data get storage guikit:cnd items
scoreboard players set #ci guikit.tmp 0
function guikit:cond/comp_step
scoreboard players operation #cond guikit.tmp = #cacc guikit.tmp
execute if score #cnot guikit.tmp matches 1 run function guikit:cond/negate
data remove storage guikit:cnd items
data remove storage guikit:cnd cur
function guikit:internal/clear_cond
return run scoreboard players get #cond guikit.tmp
