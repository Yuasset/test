# WoWTR — OctoWoW / Vanilla uyarlaması

`octowow` dalı, WoWTR 26.1005'in mevcut Türkçe çeviri verilerini Vanilla 1.12 API'si ve Lua 5.0 üzerinde kullanmak için hazırlanmıştır. Ana `main` dalındaki özgün paket korunur. ClassicAPI veya başka bir DLL bu uyarlamanın bağımlılığı değildir.

`26.1005-octo.2` sürümü OctoWoW 1.18.1 (7272) içinde kullanıcı tarafından çalıştırıldı. `26.1005-octo.3`, görev çevirisini ana oyun penceresine taşır; büyü kitabı, beceriler, karakter, harita, çanta, satıcı, banka, posta ve menü metinlerini ekran oluşturulurken ve yenilenirken çevirir. Yerel OctoWoW arşivlerindeki gerçek FrameXML dosyaları incelenerek hazırlanmıştır. Bu sürümün oyun içindeki görsel kontrolü bekleniyor.

Bu paket henüz oyunun tamamını %100 Türkçeleştirmez. Mevcut verilerde bulunmayan özel sunucu metinleri ve kalan arayüz kayıtları için yeni çeviri gerekir. Otomatik kod kontrollerinin geçmesi, tüm içeriğin çevrildiğini veya gerçek oyunda hata olmayacağını garanti etmez. Oyuncu sohbetleri ve oyuncu/karakter özel adları kullanıcının seçimiyle özgün kalır.

## Kurulum ve güncelleme

Oyun ve launcher kapalıyken, mevcut temiz Git kurulumunda:

```powershell
git -C 'C:\Games\WOW\Interface\Addons\WoWTR' fetch origin octowow
git -C 'C:\Games\WOW\Interface\Addons\WoWTR' switch octowow
git -C 'C:\Games\WOW\Interface\Addons\WoWTR' merge --ff-only origin/octowow
```

İlk kurulumda yerel `octowow` dalı yoksa ikinci komut yerine `git -C 'C:\Games\WOW\Interface\Addons\WoWTR' switch --track -c octowow origin/octowow` kullanın. Hazırlanan `OctoWoW-kur.cmd` dosyası hem ilk kurulumda hem güncellemede aynı işlemi yapar. Oyun klasörü farklıysa yolu ona göre değiştirin. Launcher klasörde `WoWTR.toc` dosyasını okur; güncelleme takibi için yerel dal `octowow` olarak kalmalıdır. Launcher'ın “Add custom git addon” alanı Git dalı seçmediği için yalnızca repo URL'sini eklemek yeniden `main` sürümünü kurar.

ZIP kurulumu: `WoWTR` klasörü doğrudan `Interface\AddOns` altında olmalı; `WoWTR\WoWTR.toc` bulunmalıdır. ZIP kurulumu Git güncelleme takibi içermez.

Karakter seçimindeki **AddOns** ekranında WoWTR'yi etkinleştirin. Başka bir görev çevirisi eklentisi varsa aynı anda çalıştırmayın. Veri kapsamı geniş olduğu için AddOn bellek sınırını en az 128 MB olarak ayarlayın; mevcut OctoWoW kurulumunda bu sınır 512000 KB'dir.

## Özellikler

| Alan | Davranış |
|---|---|
| Görev kabulü, günlük ve teslim | Ana görev penceresindeki başlık, açıklama ve hedefler çevrilir; ayrı okuma paneli ayarlardan açılabilir |
| Görev ID'si | İstemci sağlıyorsa doğrudan ID; aksi durumda İngilizce başlık ve hedef başlangıcıyla eşleştirme |
| NPC diyalogları | Eşleşen metinler ve seçenekler WoWTR hash veritabanından çevrilir |
| Kitap ve mektuplar | Başlık, sayfa ve metin hash'iyle WoWTR kitap kayıtları bulunur |
| Tooltip | Eşya/büyü tooltip satırları her oluşturma ve yenilemede hemen çevrilir; mevcut eklenti işlemleri ve API dönüş değerleri korunur |
| NPC konuşmaları | Türkçe sohbet satırı; eşleşen erişilebilir konuşma balonu yazıları da değiştirilir |
| Öğreticiler | İstemcinin sunduğu öğretici yazıları veritabanıyla eşleşirse çevrilir |
| Altyazı | Yalnızca istemcinin Lua'ya sunduğu altyazı yazıları çevrilir; eski istemcide erişilemeyen video içi metinler desteklenmez |
| Arayüz | Oyun pencerelerinin metinleri mevcut veritabanı ve ek sözlükle eşleştirilir; büyü/beceri adları, bölge adları ve desteklenen sayısal şablonlar dahil |
| Özel örnekler | Dönüş Taşı konumu ve Kan Hiddeti açıklamasındaki OctoWoW değerleri korunarak çevrilir |
| Ayarlar | `/wowtr`, mini harita düğmesi, modül seçimleri ve yazı boyutu |
| İsteğe bağlı otomasyon | Gri eşya satışı ve zindan savaş kaydı; başlangıçta kapalı |
| Tanı | Hatalar ve bulunamayan metinler sınırlı sayıda kaydedilir |

Görev çevirileri paketin `Source/Era/QuestData1_TR.lua` veritabanından gelir (4.288 kayıt). Retail'de değiştirilmiş görev metinlerini Vanilla görevlerine karıştırmamak için Retail görev dosyası yüklenmez. Diğer veriler mevcut WoWTR paketinden türetilir ve çeviri içerikleri korunur.

OctoWoW'a özgü yeni görev ve metinler mevcut WoWTR veritabanında yoksa özgün dilinde kalır. Ek sözlükte 889 doğrudan eşleştirme ve ayrıca değişken değerleri koruyan şablonlar bulunur. İstemcinin GlobalStrings kayıtları üzerindeki filtrelenmiş taramada 3.085 sabit adaydan 1.187'sine farklı bir karşılık bulunmuştur; 1.893 sabit adayın karşılığı bulunamamıştır, 5 ad bilinçli olarak özgün kalır. 846 biçim şablonu çalışma anında doğrulama gerektirir. Bu sayılar oyunun tamamının yüzdesi değildir ve bulunan karşılıkların dil/bağlam kalitesini tek başına doğrulamaz. Sunucunun görev/eşya/diyalog veritabanının tamamı bu taramaya dahil değildir.

Aynı adlı zincir görevlerinde yeterli ayırt edici bilgi yoksa yanlış çeviri seçilmez. `/wowtr durum` adayları gösterir; doğru kayıt biliniyorsa `/wowtr id 123` ile açık göreve bağlanabilir. `/wowtr log` çevrilemeyen arayüz ve açıklama metinlerini en fazla 1000 örnek olarak kaydeder. Eksik sayısı yalnızca yakalanan örnekleri belirtir; `0` yazması tüm oyunun tamamlandığı anlamına gelmez.

## İlk oyun testi

1. Girişten sonra `/wowtr durum`: sürüm `26.1005-octo.3`, hata sayısı 0 olmalı.
2. `/wowtr`: ayar penceresini açıp kapatın; mini harita düğmesini deneyin.
3. Bir temel Vanilla görevinin kabul, günlük ve teslim metinlerinin ana oyun penceresinde Türkçe olduğunu kontrol edin. Ayrı paneli denemek isterseniz `/wowtr` ayarlarından açın.
4. Çantadaki bir eşyanın üzerinde fareyi 10 saniye tutun: çevrilen satırlar İngilizceye geri dönmemeli. Sonra başka eşyaya geçin; önceki eşyanın çevirisi yeni eşyanın üzerinde kalmamalı. Ekipman ve sohbetteki eşya bağlantılarını da deneyin.
5. Büyü kitabını, becerileri, sağlık yazısını, mini harita başlığını ve ESC menüsünü kontrol edin. Dönüş Taşı ile Kan Hiddeti açıklamalarında sayılar doğru kalmalı. `/wowtr` içinden açıklama/arayüz çevirisini kapatıp açın; özgün metin ve çeviri doğru biçimde geri gelmeli.
6. Sorun varsa `/wowtr log` penceresinden metni kopyalayın. Oyundan normal çıkınca kayıt `WTF\Account\<hesap>\SavedVariables\WoWTR.lua` dosyasına da yazılır.

## Geri dönüş

Oyun ve launcher kapalıyken `git -C 'C:\Games\WOW\Interface\Addons\WoWTR' switch main` özgün sürüme döndürür. Uyarlamanın ayarları `WoWTRVanillaDB` adlı ayrı SavedVariables tablosundadır. Özgün WoWTR'nin SavedVariables isimleri de `.toc` içinde tutulur; varsa eski ayarlar oyun çıkışında silinmez.

## Veri ve kaynaklar

Türkçe çeviri verileri ve fontlar özgün WoWTR paketine aittir; mevcut hak ve sahiplik koşulları geçerlidir. İngilizce görev adları, ID'ler ve hedef başlangıçları için olgusal eşleştirme indeksi [QuestTranslator-Vanilla-Turkish / QuestList.lua](https://github.com/devteabct78/QuestTranslator-Vanilla-Turkish/blob/main/QuestList.lua) verisinden üretilmiştir. Eksik İngilizce görev adları ve ID'leri [pfQuest](https://github.com/shagu/pfQuest/blob/master/db/enUS/quests.lua) verisinden eklenmiştir. Bu projelerin oyun kodu veya Türkçe çevirileri kopyalanmamıştır.

`tools/build_vanilla_data.lua` verileri yeniden üretir. Lua 5.0 ile repo kökünde çalıştırın. `tests/vanilla_spec.lua` Vanilla API biçimini taklit ederek görev eşleştirmesini, olay akışlarını, özgün metne dönüşü, UI oluşturmayı ve otomasyon sınırlarını denetler. Bu kontroller gerçek oyun testinin yerine geçmez.
