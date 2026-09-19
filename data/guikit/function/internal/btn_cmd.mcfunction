# macro: $(cmd)     as player
# Runs with the permission level datapack functions get (function-permission-level, default 2),
# not the player's own. cmd must come from menu code / definitions, never from player input.
$execute as @s at @s run $(cmd)
