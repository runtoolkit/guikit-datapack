# guikit :: cond/t_score    storage guikit:cond {obj, [min], [max]}
execute unless data storage guikit:cond obj run return 0
execute unless data storage guikit:cond min run data modify storage guikit:cond min set value -2147483648
execute unless data storage guikit:cond max run data modify storage guikit:cond max set value 2147483647
function guikit:cond/t_score_do with storage guikit:cond
