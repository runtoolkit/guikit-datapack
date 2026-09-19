# demo :: on_close     (via #guikit:on_close, as the player whose menu just closed)
# Runs on EVERY close, including the implicit one api/open does before opening the next menu,
# so only reset state here that is safe to lose in that case. `demo.armed` (the danger button's
# "click again to confirm" flag) qualifies: leaving the menu should disarm it.
tag @s remove demo.armed
