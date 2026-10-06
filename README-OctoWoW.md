# WoWTR — OctoWoW / Vanilla uyarlaması

`octowow` dalı, WoWTR 26.1005'in mevcut Türkçe çeviri verilerini Vanilla 1.12 API'si ve Lua 5.0 üzerinde kullanmak için hazırlanmıştır. Ana `main` dalındaki özgün paket korunur. ClassicAPI veya başka bir DLL bu uyarlamanın bağımlılığı değildir.

Bu ilk sürüm otomatik Lua 5.0 kontrollerinden geçirilmiştir. OctoWoW 1.18.1 (7272) üzerinde gerçek karakterle oyun testi henüz yapılmamıştır.

## Kurulum ve güncelleme

Oyun ve launcher kapalıyken, mevcut temiz Git kurulumunda:

```powershell
git -C 'C:\Games\WOW\Interface\Addons\WoWTR' fetch origin octowow
git -C 'C:\Games\WOW\Interface\Addons\WoWTR' switch --track -c octowow origin/octowow
```

`octowow` dalı zaten yerelde varsa ikinci komut yerine `git ... switch octowow` kullanın. Oyun klasörü farklıysa yolu ona göre değiştirin. Launcher klasörde `WoWTR.toc` dosyasını okur; güncelleme takibi için yerel dal `octowow` olarak kalmalıdır. Launcher'ın “Add custom git addon” alanı Git dalı seçmediği için yalnızca repo URL'sini eklemek yeniden `main` sürümünü kurar.

ZIP kurulumu: `WoWTR` klasörü doğrudan `Interface\AddOns` altında olmalı; `WoWTR\WoWTR.toc` bulunmalıdır. ZIP kurulumu Git güncelleme takibi içermez.

Karakter seçimindeki **AddOns** ekranında WoWTR'yi etkinleştirin. Başka bir görev çevirisi eklentisi varsa aynı anda çalıştırmayın. Veri kapsamı geniş olduğu için AddOn bellek sınırını en az 128 MB olarak ayarlayın; mevcut OctoWoW kurulumunda bu sınır 512000 KB'dir.

## Özellikler

| Alan | Davranış |
|---|---|
| Görev kabulü, günlük ve teslim | Özgün oyun penceresinin yanında Türkçe okuma paneli; EN/TR geçişi |
| Görev ID'si | İstemci sağlıyorsa doğrudan ID; aksi durumda İngilizce başlık ve hedef başlangıcıyla eşleştirme |
| NPC diyalogları | Eşleşen metinler ve seçenekler WoWTR hash veritabanından çevrilir |
| Kitap ve mektuplar | Başlık, sayfa ve metin hash'iyle WoWTR kitap kayıtları bulunur |
| Tooltip | Eşya/büyü tooltip satırları; sayısal `$1` vb. yer tutucuları korunur |
| NPC konuşmaları | Türkçe sohbet satırı; eşleşen erişilebilir konuşma balonu yazıları da değiştirilir |
| Öğreticiler | İstemcinin sunduğu öğretici yazıları veritabanıyla eşleşirse çevrilir |
| Altyazı | Yalnızca istemcinin Lua'ya sunduğu altyazı yazıları çevrilir; eski istemcide erişilemeyen video içi metinler desteklenmez |
| Arayüz | Görev ekranındaki temel düğme ve bölüm başlıkları |
| Ayarlar | `/wowtr`, mini harita düğmesi, modül seçimleri ve yazı boyutu |
| İsteğe bağlı otomasyon | Gri eşya satışı ve zindan savaş kaydı; başlangıçta kapalı |
| Tanı | Hatalar ve bulunamayan metinler sınırlı sayıda kaydedilir |

Görev çevirileri paketin `Source/Era/QuestData1_TR.lua` veritabanından gelir (4.288 kayıt). Retail'de değiştirilmiş görev metinlerini Vanilla görevlerine karıştırmamak için Retail görev dosyası yüklenmez. Diğer veriler mevcut WoWTR paketinden türetilir ve çeviri içerikleri korunur.

OctoWoW'a özgü yeni görev ve metinler mevcut WoWTR veritabanında yoksa özgün dilinde kalır. Aynı adlı zincir görevlerinde yeterli ayırt edici bilgi yoksa yanlış çeviri seçilmez. `/wowtr durum` adayları gösterir; doğru kayıt biliniyorsa `/wowtr id 123` ile açık göreve bağlanabilir.

## İlk oyun testi

1. Girişten sonra `/wowtr durum`: sürüm `26.1005-octo.1`, hata sayısı 0 olmalı.
2. `/wowtr`: ayar penceresini açıp kapatın; mini harita düğmesini deneyin.
3. Bir temel Vanilla görevinin kabul, günlük ve teslim metinlerini açın; EN/TR düğmesini deneyin.
4. Bir NPC diyalogu, kitap ve eşya tooltip'i açın.
5. Sorun varsa `/wowtr log` penceresinden metni kopyalayın. Oyundan normal çıkınca kayıt `WTF\Account\<hesap>\SavedVariables\WoWTR.lua` dosyasına da yazılır.

## Geri dönüş

Oyun ve launcher kapalıyken `git -C 'C:\Games\WOW\Interface\Addons\WoWTR' switch main` özgün sürüme döndürür. Uyarlamanın ayarları `WoWTRVanillaDB` adlı ayrı SavedVariables tablosundadır.

## Veri ve kaynaklar

Türkçe çeviri verileri ve fontlar özgün WoWTR paketine aittir; mevcut hak ve sahiplik koşulları geçerlidir. İngilizce görev adları, ID'ler ve hedef başlangıçları için olgusal eşleştirme indeksi [QuestTranslator-Vanilla-Turkish / QuestList.lua](https://github.com/devteabct78/QuestTranslator-Vanilla-Turkish/blob/main/QuestList.lua) verisinden üretilmiştir. Eksik İngilizce görev adları ve ID'leri [pfQuest](https://github.com/shagu/pfQuest/blob/master/db/enUS/quests.lua) verisinden eklenmiştir. Bu projelerin oyun kodu veya Türkçe çevirileri kopyalanmamıştır.

`tools/build_vanilla_data.lua` verileri yeniden üretir. Lua 5.0 ile repo kökünde çalıştırın. `tests/vanilla_spec.lua` Vanilla API biçimini taklit ederek görev eşleştirmesini, olay akışlarını, özgün metne dönüşü, UI oluşturmayı ve otomasyon sınırlarını denetler. Bu kontroller gerçek oyun testinin yerine geçmez.
