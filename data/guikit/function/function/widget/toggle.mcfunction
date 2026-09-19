# guikit :: widget/toggle   as player   storage guikit:in {obj:"my_score"}
# Result: new state (0/1)
function guikit:internal/toggle with storage guikit:in
scoreboard players set @s guikit.dirty 1
