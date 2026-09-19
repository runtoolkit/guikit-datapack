# guikit — Minecraft GUI framework (datapack)

`guigenmc` (JSON → datapack üreteci) mantığının, **config yerine klasik datapack framework**
olarak yeniden yazılmış hâli. Menüleri JSON'la tanımlamazsın; `.mcfunction` yazarsın ve
`guikit:` fonksiyonlarını çağırırsın.

Hedef: Minecraft Java **1.21.5+** (`pack_format`/`min_format` 119, kaynağındaki değerle aynı).

## Mekanik (kaynakla aynı)
`chest_minecart` üzerine `item replace` ile widget item'ları basılır → oyuncu **shift-click**
yapınca item envantere düşer → `clear ... ` ile tespit edilir → handler çalışır → item silinir →
gerekirse yeniden çizilir.

## Kaynaktan farklar
| guigenmc (generator) | guikit (framework) |
|---|---|
| JSON → tek pakete üretilmiş fonksiyonlar | Sabit çekirdek + **senin yazdığın** menü kodu |
| Her tick tüm slotlar yeniden basılır | Sadece `guikit.dirty=1` iken yeniden çizilir |
| Cart `sort=nearest` ile bulunur | Cart, oyuncuya **uid** ile bağlı (çok oyunculu güvenli) |
| Toggle/counter/cycle/random/cost/cooldown metin şablonu | `guikit:widget/*` paylaşılan helper'lar |
| Menüler tek pakette | Menüler ayrı datapack/namespace olabilir (`#guikit:register` vb.) |

## Menü nasıl yazılır
1. `#guikit:register` → `data modify storage guikit:reg menus."ns:id" set value {alias:"ns_id", container:"chest_minecart"}`
2. `#guikit:fill`     → menünün o anki sayfasını çizer (`guikit:widget/pad` sonra `guikit:widget/draw`)
3. `#guikit:probe`    → tıklanabilir her widget için **bir satır**: `{id, fn}` + `guikit:widget/probe`
4. `#guikit:clear_tags` → `tag @s remove guikit.m.<alias>`
5. `storage guikit:in {menu:"ns:id"}` + `function guikit:api/open`

Tam çalışan örnek: `data/demo/` (2 sayfa; button, toggle, counter, cycle, progress, nav, close, random, confirm, cost, cooldown).
Aç: `/function demo:open`

## Widget helper'ları (`guikit:widget/*`)
`draw` `pad` `probe` `toggle` `counter` `cycle` `progress` `roll` `goto_page` `cooldown_start` `pay_item` `pay_score` `say`

## ⚠ Doğrulama durumu — dürüst not
- **`mecha .` → `Done!`, çıkış kodu 0.** Ama mecha **`$` ile başlayan makro satırlarını doğrulamaz**
  (bilerek bozuk bir `$scoreboard players zzzbozuk` satırını da geçirdi). Bu yüzden 42 makro satırını ayrıca
  `$(x)` yerlerine gerçekçi değerler koyup mecha'ya normal komut olarak verdim → hepsi geçerli.
- Statik lint temiz. `counter`/`toggle`/`cycle`/`progress` aritmetiği yorumlayıcı simülasyonunda 15/15 geçti.
- **Bu adımda bulunup düzeltilen gerçek hata:** `data modify storage X set value {...}` geçersizdi
  (`<path>` zorunlu) → 42 satır / 17 dosyada `X {} set value` yapıldı. Önceki teslimde paket bu yüzden yüklenmezdi.
- **Hâlâ yapılmadı:** gerçek Minecraft'ta çalıştırma. Mecha sözdizimini doğrular, davranışı değil
  (`clear` + `custom_data` eşleşmesi, `summon`, tick sırası, çok oyunculu davranış test edilmedi).

## Bilinen sınırlar
- `guikit:widget/pad` her zaman 27 slot basar → `hopper_minecart` (5 slot) ile **kullanma**.
- `demo` içinde `if score matches N run data modify ... guikit:w set value` kalıbı: skor hiçbir
  aralığa uymazsa `guikit:w` önceki widget'ın verisini taşır ve o yeniden çizilir. Skorları çizmeden
  önce init et (demo yapıyor) ya da bir `else` satırı ekle.
- `name`/`lore` alanları makroya **ham SNBT string** olarak girer. Tanım satırında `name:'...'` yazıyorsan
  metin içinde `'` geçerse **tanım satırı** geçersiz olur (mecha ile doğrulandı); `Bob\'s` şeklinde kaçır.
  Genişletilmiş `item replace` komutunun kendisi `'` içeren metinle sorunsuz.
- `confirm` demo'da "iki tıkla onay" olarak basitleştirildi (kaynaktaki gibi ayrı sayfa değil).
- Kaynaktaki `condition` (item_count/score/tag/gamemode/advancement) ayrı helper olarak **yazılmadı**;
  bunlar zaten tek satırlık `execute if ...` olduğundan handler içinde elle yazılır.
- Kaynaktaki `link` widget'ı yok (`tellraw` + `click_event` open_url; tek satırlık, handler içinde yazılır).
