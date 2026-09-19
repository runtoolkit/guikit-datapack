# macro: $(url)     as player     (the game only opens http/https links)
$tellraw @s [{"text":"[GUI] ","color":"gray"},{"text":"$(url)","color":"aqua","underlined":true,"click_event":{"action":"open_url","url":"$(url)"}}]
