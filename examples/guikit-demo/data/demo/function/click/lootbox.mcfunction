# every click keeps the menu alive
scoreboard players set @s guikit.timer 1200

# roll 0..99 -> #roll guikit.tmp
function guikit:internal/clear_in
data merge storage guikit:in {max:99}
function guikit:widget/roll

# Tiers: 0..69 dirt (70%) | 70..94 iron (25%) | 95..99 diamond (5%)
# Only open-ended ranges (N..) are used and first match wins through
# "return run", so no closed "A..B" range is needed. The reward itself is a
# plain "give" inside its own function instead of "execute ... run give".
execute if score #roll guikit.tmp matches 95.. run return run function demo:internal/reward_diamond
execute if score #roll guikit.tmp matches 70.. run return run function demo:internal/reward_iron
function demo:internal/reward_dirt
