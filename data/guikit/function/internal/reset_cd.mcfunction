# guikit :: internal/reset_cd     as player     (reward of the advancement guikit:interact_cart)
# Restarts the MENU TIMEOUT (`guikit.timer`, the countdown that closes an idle menu) when the player
# interacts with (right-clicks) a guikit cart. NOT the cooldown scoreboard `guikit.cd`, despite the name.
# It restores the value the menu was opened with (`guikit.tmax`, set by api/open). Clicking widgets inside
# the open GUI does NOT reset the timer any more.
# The advancement is granted only once, so it has to be revoked here or it could never fire again.
advancement revoke @s only guikit:interact_cart
execute if score @s guikit.uid matches 1.. if score @s guikit.tmax matches 1.. run scoreboard players operation @s guikit.timer = @s guikit.tmax
