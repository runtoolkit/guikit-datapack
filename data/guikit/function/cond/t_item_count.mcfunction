# guikit :: cond/t_item_count    storage guikit:cond {item, [min]}
execute unless data storage guikit:cond item run return 0
execute unless data storage guikit:cond min run data modify storage guikit:cond min set value 1
function guikit:cond/t_item_count_do with storage guikit:cond
