# guikit :: internal/btn_pay     as player     reads storage guikit:btn cur.cost
# Charges the cost through the existing helpers. Result in #paid guikit.tmp (1 = paid, 0 = not enough).
execute unless data storage guikit:btn cur.cost.count run data modify storage guikit:btn cur.cost.count set value 1
execute if data storage guikit:btn cur.cost.obj run function guikit:internal/pay_score with storage guikit:btn cur.cost
execute if data storage guikit:btn cur.cost.item run function guikit:internal/btn_pay_item
