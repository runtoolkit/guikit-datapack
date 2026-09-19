# guikit :: internal/cleanup_scores
# Resets the transient fake-player scores. Permanent ones (#version, #next_uid in guikit.const) are kept.
scoreboard players reset #uid guikit.tmp
scoreboard players reset #found guikit.tmp
scoreboard players reset #hit guikit.tmp
scoreboard players reset #gui guikit.tmp
scoreboard players reset #left guikit.tmp
scoreboard players reset #wcount guikit.tmp
scoreboard players reset #have guikit.tmp
scoreboard players reset #paid guikit.tmp
scoreboard players reset #cond guikit.tmp
scoreboard players reset #draw_ok guikit.tmp
scoreboard players reset #btn_close guikit.tmp
scoreboard players set #ok guikit.const 0
