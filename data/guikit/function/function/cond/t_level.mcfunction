# guikit :: cond/t_level    storage guikit:cond {[min], [max]}
# XP level (the number shown above the hotbar), NOT a scoreboard objective -- `score` cannot read it.
# At least one of min/max should be given; with neither, any level passes (min defaults to 0).
# Same two-open-ended-ranges rule as t_score_do (see README "Validation status").
execute unless data storage guikit:cond min run data modify storage guikit:cond min set value 0
execute unless data storage guikit:cond max run data modify storage guikit:cond max set value 2147483647
function guikit:cond/t_level_do with storage guikit:cond
