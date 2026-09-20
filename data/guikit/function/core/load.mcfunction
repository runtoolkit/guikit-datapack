# guikit :: load
scoreboard objectives add guikit.timer dummy
scoreboard objectives add guikit.tmax dummy
scoreboard objectives add guikit.click dummy
scoreboard objectives add guikit.page dummy
scoreboard objectives add guikit.tmp dummy
scoreboard objectives add guikit.rand dummy
scoreboard objectives add guikit.cd dummy
scoreboard objectives add guikit.dirty dummy
scoreboard objectives add guikit.uid dummy
scoreboard objectives add guikit.const dummy
scoreboard objectives add guikit.slots dummy
scoreboard objectives add guikit.drop minecraft.custom:minecraft.drop

scoreboard players set #version guikit.const 2
# uid counter is only initialised once so uids stay unique across reloads
execute unless score #next_uid guikit.const matches 0.. run scoreboard players set #next_uid guikit.const 1

# transient scratch storage / scores are dropped on every reload (stale state from a previous run)
function guikit:internal/clear/in
function guikit:internal/clear/w
function guikit:internal/clear/cond
function guikit:internal/clear/tmp
function guikit:internal/btn/clear_cur
function guikit:internal/clear/mtr
function guikit:internal/clear/scores

# carts that lost their owner across a reload / relog are removed
function guikit:internal/sweep/orphans

# registry is rebuilt on every reload by the #guikit:register listeners
data modify storage guikit:reg menus set value {}
function guikit:internal/summon/builtin
data modify storage guikit:cont bound set value {}
data modify storage guikit:btn defs set value {}
function #guikit:register
