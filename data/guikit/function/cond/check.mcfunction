# guikit :: cond/check    as player    storage guikit:cond = {type:"...", ..., not:1b}
# Result: #cond guikit.tmp = 1 (passed) / 0 (failed), and the same value is returned.
#
# Types (keys in brackets are optional):
#   score        {obj:"coins", [min:N], [max:N]}      unset score = fails
#   item_count   {item:"minecraft:diamond", [min:N]}  min defaults to 1; plain id or #tag only
#   tag          {tag:"vip"}
#   gamemode     {mode:"survival"}                    survival | creative | adventure | spectator
#   advancement  {adv:"minecraft:story/root"}
#   predicate    {pred:"ns:name"}
#   level        {[min:N], [max:N]}                    XP level (not a scoreboard); both optional
#   all / any    {of:[{type:..}, {type:..}]}           every / at least one element passes. Elements must be
#                                                      leaf types above (a nested all/any counts as failed)
# `not:1b` inverts the result. Unknown type / missing key = fails (closed).
#
#   function guikit:internal/clear/cond
#   data merge storage guikit:cond {type:"score", obj:"coins", min:10}
#   function guikit:cond/check
#   execute if score #cond guikit.tmp matches 1 run ...
#
# One small function per type (no big execute chains), same as the rest of the pack.
scoreboard players set #cond guikit.tmp 0
execute if data storage guikit:cond {type:"all"} run function guikit:cond/t_all
execute if data storage guikit:cond {type:"any"} run function guikit:cond/t_any
execute if data storage guikit:cond {type:"score"} run function guikit:cond/t_score
execute if data storage guikit:cond {type:"item_count"} run function guikit:cond/t_item_count
execute if data storage guikit:cond {type:"tag"} if data storage guikit:cond tag run function guikit:cond/t_tag with storage guikit:cond
execute if data storage guikit:cond {type:"gamemode"} if data storage guikit:cond mode run function guikit:cond/t_gamemode with storage guikit:cond
execute if data storage guikit:cond {type:"advancement"} if data storage guikit:cond adv run function guikit:cond/t_advancement with storage guikit:cond
execute if data storage guikit:cond {type:"predicate"} if data storage guikit:cond pred run function guikit:cond/t_predicate with storage guikit:cond
execute if data storage guikit:cond {type:"level"} run function guikit:cond/t_level
execute if data storage guikit:cond {not:1b} run function guikit:cond/negate
return run scoreboard players get #cond guikit.tmp
