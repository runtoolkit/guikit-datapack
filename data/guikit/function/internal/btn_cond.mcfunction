# guikit :: internal/btn_cond     as player     reads storage guikit:btn cur.cond
# Result: #cond guikit.tmp = 1 when the button has no condition or it passes, else 0.
scoreboard players set #cond guikit.tmp 1
execute unless data storage guikit:btn cur.cond run return 1
function guikit:internal/clear_cond
data remove storage guikit:cnd cur
data modify storage guikit:cnd cur set from storage guikit:btn cur.cond
function guikit:cond/load_cur
function guikit:cond/check
