# guikit :: cond/t_any     storage guikit:cond {type:"any", of:[{...}, ...], [not]}
# Passes when AT LEAST ONE element passes (empty list = fails). See cond/comp_run.
scoreboard players set #cmode guikit.tmp 1
scoreboard players set #cacc guikit.tmp 0
return run function guikit:cond/comp_run
