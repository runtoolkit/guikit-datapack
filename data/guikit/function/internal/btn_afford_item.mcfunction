# guikit :: internal/btn_afford_item     as player
# Reuses the item_count condition, which does not count the clicked widget item (see cond/t_item_count_do).
scoreboard players set #cond guikit.tmp 0
function guikit:internal/clear_cond
data modify storage guikit:cond item set from storage guikit:btn cur.cost.item
data modify storage guikit:cond min set from storage guikit:btn cur.cost.count
function guikit:cond/t_item_count_do with storage guikit:cond
function guikit:internal/clear_cond
