# guikit :: cond/load_cur     copies the condition compound in storage guikit:cnd cur into guikit:cond, key by key
# (a root-level `data modify storage X {} set from ...` is avoided on purpose, see README "Validation status").
# Call internal/clear_cond first. Keep this list in sync with internal/clear_cond.
execute if data storage guikit:cnd cur.type run data modify storage guikit:cond type set from storage guikit:cnd cur.type
execute if data storage guikit:cnd cur.obj run data modify storage guikit:cond obj set from storage guikit:cnd cur.obj
execute if data storage guikit:cnd cur.min run data modify storage guikit:cond min set from storage guikit:cnd cur.min
execute if data storage guikit:cnd cur.max run data modify storage guikit:cond max set from storage guikit:cnd cur.max
execute if data storage guikit:cnd cur.item run data modify storage guikit:cond item set from storage guikit:cnd cur.item
execute if data storage guikit:cnd cur.tag run data modify storage guikit:cond tag set from storage guikit:cnd cur.tag
execute if data storage guikit:cnd cur.mode run data modify storage guikit:cond mode set from storage guikit:cnd cur.mode
execute if data storage guikit:cnd cur.adv run data modify storage guikit:cond adv set from storage guikit:cnd cur.adv
execute if data storage guikit:cnd cur.pred run data modify storage guikit:cond pred set from storage guikit:cnd cur.pred
execute if data storage guikit:cnd cur.not run data modify storage guikit:cond not set from storage guikit:cnd cur.not
execute if data storage guikit:cnd cur.of run data modify storage guikit:cond of set from storage guikit:cnd cur.of
