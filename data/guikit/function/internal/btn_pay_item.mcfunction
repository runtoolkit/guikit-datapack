# guikit :: internal/btn_pay_item     as player
# The clicked widget is still in the inventory here. Remove widget items first so pay_item can neither
# count it nor clear it instead of the player's real items (a button that costs its own item type).
function guikit:internal/safe_clear
function guikit:internal/pay_item with storage guikit:btn cur.cost
