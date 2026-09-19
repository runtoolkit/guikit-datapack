# guikit :: widget/pay_score   as player   storage guikit:in {obj:"coins", amount:50}
function guikit:internal/pay_score with storage guikit:in
return run scoreboard players get #paid guikit.tmp
