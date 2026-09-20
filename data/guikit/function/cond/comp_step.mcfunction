# guikit :: cond/comp_step     as player     one element per call, recurses until the list is done or the result is decided
execute unless score #ci guikit.tmp < #cn guikit.tmp run return 0
execute store result storage guikit:cnd i int 1 run scoreboard players get #ci guikit.tmp
function guikit:cond/comp_pick with storage guikit:cnd
function guikit:internal/clear/cond
function guikit:cond/load_cur
scoreboard players set #cond guikit.tmp 0
execute unless data storage guikit:cond {type:"all"} unless data storage guikit:cond {type:"any"} run function guikit:cond/check
execute if score #cmode guikit.tmp matches 0 if score #cond guikit.tmp matches 0 run scoreboard players set #cacc guikit.tmp 0
execute if score #cmode guikit.tmp matches 1 if score #cond guikit.tmp matches 1 run scoreboard players set #cacc guikit.tmp 1
scoreboard players add #ci guikit.tmp 1
# decided already: all stops at the first failure, any at the first pass
execute if score #cmode guikit.tmp matches 0 if score #cacc guikit.tmp matches 0 run return 0
execute if score #cmode guikit.tmp matches 1 if score #cacc guikit.tmp matches 1 run return 0
function guikit:cond/comp_step
