# guikit :: internal/btn/gate     as player     reads storage guikit:btn cur
# Result: #cond guikit.tmp = 1 when the button's cond passes AND its cost is affordable, else 0.
# Nothing is charged here (used when drawing, to decide the locked look).
function guikit:internal/btn/cond
execute if score #cond guikit.tmp matches 0 run return 0
execute if data storage guikit:btn cur.cost run function guikit:internal/btn/afford
