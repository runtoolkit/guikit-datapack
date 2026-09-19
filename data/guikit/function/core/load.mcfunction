# guikit :: load
scoreboard objectives add guikit.timer dummy
scoreboard objectives add guikit.click dummy
scoreboard objectives add guikit.page dummy
scoreboard objectives add guikit.tmp dummy
scoreboard objectives add guikit.rand dummy
scoreboard objectives add guikit.cd dummy
scoreboard objectives add guikit.dirty dummy
scoreboard objectives add guikit.uid dummy
scoreboard objectives add guikit.const dummy

scoreboard players set #version guikit.const 1
# uid counter is only initialised once so uids stay unique across reloads
execute unless score #next_uid guikit.const matches 0.. run scoreboard players set #next_uid guikit.const 1

# transient scratch storage / scores are dropped on every reload (stale state from a previous run)
function guikit:internal/clear_in
function guikit:internal/clear_w
function guikit:internal/clear_cond
function guikit:internal/clear_tmp
function guikit:internal/clear_btn_cur
function guikit:internal/cleanup_scores

# carts that lost their owner across a reload / relog are removed
function guikit:internal/sweep_orphans

# registry is rebuilt on every reload by the #guikit:register listeners
data modify storage guikit:reg menus set value {}
data modify storage guikit:btn defs set value {}
function #guikit:register
