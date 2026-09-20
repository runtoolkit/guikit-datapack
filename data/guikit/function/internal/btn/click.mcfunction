# macro: $(id)     as player, at player      (called by widget/button_probe)
# Definition keys (storage guikit:btn defs."<id>"):
#   cmd:"..."        command run `as @s at @s`. Use `function ns:name` for several commands.
#   url:"https://.." prints a clickable link in chat instead (use close:1b so the player can see chat)
#   cond:{...}       any guikit:cond type, see cond/check. Fails -> `deny` message, nothing runs
#   deny:"..."       message when cond fails (no double quotes). Default "Not available."
#   cost:{...}       {obj:"coins", amount:5} or {item:"minecraft:diamond", [count:3]}; charged after cond passes,
#                    before cmd/url. Not enough -> `poor` message, nothing runs, nothing is taken
#   poor:"..."       message when the cost cannot be paid (no double quotes). Default "You can't afford that."
#   close:1b         close the menu after the command
#   locked_item:"minecraft:barrier"   look when cond fails or the cost is not affordable (widget/button)
data remove storage guikit:btn cur
$data modify storage guikit:btn cur set from storage guikit:btn defs."$(id)"
execute unless data storage guikit:btn cur run return 0

function guikit:internal/btn/cond
execute if score #cond guikit.tmp matches 0 run return run function guikit:internal/btn/deny

# cost: charged only now (cond passed), before the command runs
scoreboard players set #paid guikit.tmp 1
execute if data storage guikit:btn cur.cost run function guikit:internal/btn/pay
execute if score #paid guikit.tmp matches 0 run return run function guikit:internal/btn/poor

# decide now: the command may overwrite guikit:btn cur (e.g. by running another button)
execute store success score #btn_close guikit.tmp if data storage guikit:btn cur{close:1b}
execute if data storage guikit:btn cur.cmd run function guikit:internal/btn/cmd with storage guikit:btn cur
execute if data storage guikit:btn cur.url run function guikit:internal/btn/url with storage guikit:btn cur
execute if score #btn_close guikit.tmp matches 1 if score @s guikit.uid matches 1.. run function guikit:api/close

# transient: nothing may leak into the next click
function guikit:internal/btn/clear_cur
