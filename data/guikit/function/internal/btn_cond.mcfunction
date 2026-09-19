# guikit :: internal/btn_cond     as player     reads storage guikit:btn cur.cond
# Result: #cond guikit.tmp = 1 when the button has no condition or it passes, else 0.
# Copies key by key into guikit:cond (a root-level `data modify ... set from` is avoided on purpose,
# see README "Validation status"). Keep this list in sync with internal/clear_cond.
scoreboard players set #cond guikit.tmp 1
execute unless data storage guikit:btn cur.cond run return 1
function guikit:internal/clear_cond
execute if data storage guikit:btn cur.cond.type run data modify storage guikit:cond type set from storage guikit:btn cur.cond.type
execute if data storage guikit:btn cur.cond.obj run data modify storage guikit:cond obj set from storage guikit:btn cur.cond.obj
execute if data storage guikit:btn cur.cond.min run data modify storage guikit:cond min set from storage guikit:btn cur.cond.min
execute if data storage guikit:btn cur.cond.max run data modify storage guikit:cond max set from storage guikit:btn cur.cond.max
execute if data storage guikit:btn cur.cond.item run data modify storage guikit:cond item set from storage guikit:btn cur.cond.item
execute if data storage guikit:btn cur.cond.tag run data modify storage guikit:cond tag set from storage guikit:btn cur.cond.tag
execute if data storage guikit:btn cur.cond.mode run data modify storage guikit:cond mode set from storage guikit:btn cur.cond.mode
execute if data storage guikit:btn cur.cond.adv run data modify storage guikit:cond adv set from storage guikit:btn cur.cond.adv
execute if data storage guikit:btn cur.cond.pred run data modify storage guikit:cond pred set from storage guikit:btn cur.cond.pred
execute if data storage guikit:btn cur.cond.not run data modify storage guikit:cond not set from storage guikit:btn cur.cond.not
function guikit:cond/check
