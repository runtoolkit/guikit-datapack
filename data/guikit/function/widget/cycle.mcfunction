# guikit :: widget/cycle   as player
# storage guikit:in {obj:"score", n:3, last:2, wrap:1b}      (last = n-1)
function guikit:internal/cycle with storage guikit:in
scoreboard players set @s guikit.dirty 1
