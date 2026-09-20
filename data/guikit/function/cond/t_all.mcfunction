# guikit :: cond/t_all     storage guikit:cond {type:"all", of:[{...}, ...], [not]}
# Passes when EVERY element passes (empty list = passes). See cond/comp_run.
scoreboard players set #cmode guikit.tmp 0
scoreboard players set #cacc guikit.tmp 1
return run function guikit:cond/comp_run
