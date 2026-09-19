# guikit :: widget/counter   as player
# storage guikit:in {obj:"score", delta:1, min:0, max:64, wrap:0b}
# wrap:0b -> clamp to [min,max]      wrap:1b -> roll over (min<->max)
function guikit:internal/counter_step with storage guikit:in
scoreboard players set @s guikit.dirty 1
