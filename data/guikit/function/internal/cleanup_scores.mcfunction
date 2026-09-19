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
# meter widget temps (see internal/meter_hit, internal/meter_probe_loop) -- this list was never
# exhaustive to begin with (progress's own #f/#i/#d/#f2/#abs aren't reset here either, since
# every one of these is always overwritten before it's read), added for consistency with the
# other click-time scratch scores rather than because leaving them out was causing a bug.
scoreboard players reset #mw guikit.tmp
scoreboard players reset #mc guikit.tmp
scoreboard players reset #mval guikit.tmp
scoreboard players reset #mmax guikit.tmp
scoreboard players reset #mhit guikit.tmp
# added with cond/t_level and internal/cd_notify
scoreboard players reset #lvl guikit.tmp
scoreboard players reset #cdleft guikit.tmp
scoreboard players reset #pi guikit.tmp
scoreboard players reset #cd20 guikit.tmp
scoreboard players set #ok guikit.const 0
