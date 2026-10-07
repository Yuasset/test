-- Display-only UI vocabulary. Never replace game globals, command names, or API values.
local W = WoWTRV
local additions = {
    Absorb="Soğurma", ["Active Challenges:"]="Etkin Meydan Okumalar:", ["Additional Comments:"]="Ek Açıklamalar:",
    Banned="Yasaklanmış", Corrupt="Bozuk", ["Dependency banned"]="Bağımlılık yasaklanmış",
    ["Dependency corrupt"]="Bağımlılık bozuk", ["Dependency insecure"]="Bağımlılık güvensiz",
    ["Dependency out of date"]="Bağımlılık güncel değil", ["Dependency not loadable on demand"]="Bağımlılık isteğe bağlı yüklenemiyor",
    Insecure="Güvensiz", Missing="Eksik", ["Not loadable on demand"]="İsteğe bağlı yüklenemiyor",
    ["Unknown load problem"]="Bilinmeyen yükleme sorunu", ["Enter channel name"]="Kanal adını girin",
    ["Add a channel"]="Kanal Ekle", ["Enter name of friend to add:"]="Eklenecek arkadaşın adını girin:",
    ["Add Guild Rank:"]="Lonca Rütbesi Ekle:", ["Add Raid Member:"]="Baskın Üyesi Ekle:",
    ["Advanced Options"]="Gelişmiş Ayarlar", ["Configure advanced interface options"]="Gelişmiş arayüz ayarlarını düzenleyin",
    Allied="Müttefik", ["All Slots"]="Tüm Yuvalar", ["All Subclasses"]="Tüm Alt Sınıflar",
    ["Already learned"]="Zaten öğrenilmiş", Always="Her Zaman", ["Always Show ActionBars"]="Eylem Çubuklarını Daima Göster",
    ["Ambience Volume"]="Ortam Sesi", Ammo="Mühimmat", Animation="Animasyon", ["Anisotropic Filtering"]="Anizotropik Filtreleme",
    Arena="Arena", ["Conquest Points"]="Fetih Puanları", Skirmish="Çatışma", ["Arena Battles"]="Arena Savaşları",
    ["Arena team created successfully!"]="Arena takımı oluşturuldu!", ["Disband Team"]="Takımı Dağıt",
    ["Arena team disbanded successfully!"]="Arena takımı dağıtıldı!", ["Are you sure you want to disband this arena team?"]="Bu arena takımını dağıtmak istediğinizden emin misiniz?",
    Games="Maçlar", ["Gold Team Wins"]="Altın Takım Galibiyetleri", ["Green Team Wins"]="Yeşil Takım Galibiyetleri",
    ["Invite Player"]="Oyuncu Davet Et", ["Enter the name of the player you want to invite below."]="Davet etmek istediğiniz oyuncunun adını aşağıya girin.",
    ["Kick Member"]="Üyeyi Çıkar", ["Leave Team"]="Takımdan Ayrıl", ["Are you sure you want to leave this arena team?"]="Bu arena takımından ayrılmak istediğinizden emin misiniz?",
    ["Team Rating"]="Takım Puanı", Members="Üyeler", Season="Sezon", Week="Hafta", ["Win - Loss"]="Galibiyet - Mağlubiyet",
    ["Currently Assigned:"]="Mevcut Atama:", ["Attack On Assist"]="Yardım Edince Saldır",
    ["Drag an item here to include it with your mail"]="Postaya eklemek için eşyayı buraya sürükleyin",
    Power="Güç", ["Seconds per attack"]="Saldırı başına saniye", ["Attack Rating"]="Saldırı Puanı",
    ["(Must be >= the start price)"]="(Başlangıç fiyatından düşük olamaz)", ["(Auction will be set to 5 mins)"]="(Müzayede 5 dakika sürecek)",
    ["Drag an item here to auction it"]="Müzayedeye koymak için eşyayı buraya sürükleyin", Short="Kısa",
    ["Less than 30 mins"]="30 dakikadan az", Medium="Orta", ["Between 30 mins and 2hrs"]="30 dakika ile 2 saat arası",
    Long="Uzun", ["Between 2hrs and 8 hrs"]="2 ile 8 saat arası", ["Very Long"]="Çok Uzun", ["Greater than 8 hrs"]="8 saatten fazla",
    ["Auto-join Guild Recruitment Channel"]="Lonca Alım Kanalına Otomatik Katıl", ["Auto Self Cast"]="Kendine Otomatik Büyü Yap",
    ["Available Services"]="Mevcut Hizmetler", ["Average Wait Time:"]="Ortalama Bekleme Süresi:", Bag="Çanta",
    ["Only bags can go here!"]="Buraya yalnızca çantalar konabilir!", ["This item cannot stack."]="Bu eşya istiflenemez.",
    ["These items can't be swapped."]="Bu eşyaların yeri değiştirilemez.", ["That point is too far away to drop an item."]="Eşyayı bırakmak için o nokta çok uzakta.",
    ["Can't move item for unknown reason."]="Eşya bilinmeyen bir nedenle taşınamıyor.", ["That bag is full!"]="Çanta dolu!",
    ["The item is soulbound."]="Bu eşya ruha bağlı.", ["Can't place that type of item in that bag."]="Bu eşya türü o çantaya konamaz.",
    ["Carrying too many already."]="Zaten taşınabilecek en fazla miktara sahipsiniz.", ["Couldn't split those items."]="Bu eşyalar bölünemedi.",
    ["Can't place that item in that bag."]="Bu eşya o çantaya konamaz.", ["Tried to split more than number in stack."]="İstifte bulunan miktardan fazlası ayrılamaz.",
    ["Not a container."]="Bu bir çanta değil.", ["Bag is not empty."]="Çanta boş değil.", ["Not enough gold"]="Yeterli altın yok",
    ["That slot is empty."]="Bu yuva boş.", ["That slot is not empty."]="Bu yuva boş değil.", ["Bag Slot"]="Çanta Yuvası",
    ["Purchasable Bag Slot"]="Satın Alınabilir Çanta Yuvası", Barbershop="Berber", ["You are not currently in a barbershop session."]="Şu anda berberde işlem yapmıyorsunuz.",
    ["You do not have enough money."]="Yeterli paranız yok.", ["You are already in a barbershop session."]="Zaten berberde işlem yapıyorsunuz.",
    ["A system error occurred. Please try again."]="Bir sistem hatası oluştu. Lütfen yeniden deneyin.", Basic="Temel",
    ["Configure basic interface options"]="Temel arayüz ayarlarını düzenleyin", ["Change Opacity"]="Saydamlığı Değiştir",
    ["Battle Map Options"]="Savaş Haritası Ayarları", ["(Ready to Enter)"]="(Girişe Hazır)", ["Level Range:"]="Seviye Aralığı:",
    ["Battle Map"]="Savaş Haritası", ["Battlefield Instance:"]="Savaş Alanı:", ["(In Queue)"]="(Sırada)",
    ["Hold control and drag to move."]="Taşımak için Ctrl tuşunu basılı tutarak sürükleyin.", ["Battleground Finder"]="Savaş Alanı Bulucu",
    ["Left-click to open menu."]="Menüyü açmak için sol tıklayın.", ["Hold control and right-click to reset position."]="Konumu sıfırlamak için Ctrl tuşuyla sağ tıklayın.",
    ["Bindings Reset Successfully"]="Tuş atamaları sıfırlandı", ["Action Bar Functions"]="Eylem Çubuğu İşlevleri",
    ["Camera Functions"]="Kamera İşlevleri", ["Chat Functions"]="Sohbet İşlevleri", ["Interface Panel Functions"]="Arayüz Penceresi İşlevleri",
    ["Miscellaneous Functions"]="Diğer İşlevler", ["Movement Keys"]="Hareket Tuşları", ["MultiActionBar Bindings"]="Ek Eylem Çubuğu Atamaları",
    ["Raid Targeting"]="Baskın Hedefleme", ["Targeting Functions"]="Hedefleme İşlevleri", Boss="Baş Düşman", Breath="Nefes",
    Buffering="Ön Belleğe Alınıyor", Double="Çift", ["Bugs & Suggestions"]="Hatalar ve Öneriler", ["Character Classes"]="Karakter Sınıfları",
    Tradeskills="Üretim Becerileri", Miscellaneous="Diğer", ["Language Translation"]="Dil Çevirisi", Cities="Şehirler",
    ["Monsters - Balance/Abilities"]="Yaratıklar - Denge/Yetenekler", ["Monsters - Placement"]="Yaratıklar - Yerleşim",
    ["Quests & Story"]="Görevler ve Hikâye", Art="Görsel Tasarım", ["--> Please Choose a Category"]="--> Lütfen Bir Kategori Seçin",
    ["You must choose a category to submit your bug/suggestion."]="Hata veya öneri göndermek için bir kategori seçmelisiniz.",
    ["Bug submitted"]="Hata bildirimi gönderildi", ["Bug submission failed"]="Hata bildirimi gönderilemedi",
    ["Buy Back This Item"]="Bu Eşyayı Geri Al", ["Buyout auction for:"]="Hemen satın alma bedeli:", ["Detach Camera"]="Kamerayı Ayır",
    Never="Asla", Smart="Akıllı", ["Logout now"]="Şimdi Çıkış Yap", ["Cancelling this auction will cost you your deposit and:"]="Müzayedeyi iptal ederseniz depozitonuz ve şu tutar kaybolacak:",
    ["C.O.D."]="Ödemeli Posta", ["Change Instance"]="Zindanı Değiştir", ["Update Macro"]="Makroyu Güncelle", Channels="Kanallar",
    ["Talent Points:"]="Uzmanlık Puanları:", ["Skill Points:"]="Beceri Puanları:", ["Character Points Changed"]="Karakter Puanları Değişti",
    ["Lock Chat Settings"]="Sohbet Ayarlarını Kilitle", ["Chat Options"]="Sohbet Ayarları", ["Choose a box:"]="Bir kutu seçin:",
    ["Choose Stationery"]="Mektup Kâğıdı Seç", ["You have been chosen to fill out a GM survey."]="Oyun yöneticisi anketini doldurmanız için seçildiniz.",
    ["World effects suspended:"]="Dünya efektleri duraklatıldı:", ["You are no longer AFK."]="Artık uzakta değilsiniz.",
    ["You are no longer marked DND."]="Rahatsız etmeyin durumundan çıktınız.", ["Click-to-Move Camera Style"]="Tıklayarak Hareket Kamera Biçimi",
    ["Click to learn skill"]="Beceriyi öğrenmek için tıklayın", ["Remove Window"]="Pencereyi Kaldır", ["Close Log"]="Kaydı Kapat",
    ["Accepting this item will cost:"]="Bu eşyayı almak için ödenecek tutar:", ["You do not have enough money to pay the C.O.D. charges."]="Ödemeli postayı almak için yeterli paranız yok.",
    ["Color Picker"]="Renk Seçici", ["Combat Enemy"]="Düşman Savaşı", ["Combat Error"]="Savaş Hatası", ["Combat Messages"]="Savaş Mesajları",
    ["Combat Misc"]="Diğer Savaş Bilgileri", ["Combat Party"]="Grup Savaşı", ["Combat Self"]="Kendi Savaş Bilgileriniz",
    ["Floating Combat Text"]="Kayan Savaş Yazıları", Arc="Yay", ["Scroll Down"]="Aşağı Kaydır", ["Scroll Text Down"]="Yazıyı Aşağı Kaydır",
    ["Scroll Up"]="Yukarı Kaydır", ["Comments:"]="Açıklamalar:", ["Do you want to purchase a stable slot for:"]="Şu bedelle ahır yuvası almak istiyor musunuz:",
    ["Do you really want to disband your guild?"]="Loncanızı dağıtmak istediğinizden emin misiniz?",
    ["Do you really want to disable all experience gains?"]="Deneyim kazanımını kapatmak istediğinizden emin misiniz?",
    ["Do you really want to enable all experience gains?"]="Deneyim kazanımını açmak istediğinizden emin misiniz?",
    ["Contested Territory"]="Çekişmeli Bölge", ["Cooldown remaining:"]="Kalan Bekleme Süresi:", Copper="Bakır", ["Copy Name"]="Adı Kopyala",
    Corpse="Ceset", Creature="Yaratık", ["(crushing)"]="(ezici)", ["(glancing)"]="(sıyıran)", ["Currently Equipped"]="Şu Anda Kuşanılmış",
    ["Current Pet"]="Mevcut Evcil Hayvan", ["Increases weapon damage"]="Silah hasarını artırır", ["Weapon Damage"]="Silah Hasarı",
    Day="Gün", Days="Gün", Dead="Ölü", ["You are already bound here!"]="Dönüş konumunuz zaten burası!",
    ["Your soul is bound to this place."]="Ruhunuz bu yere bağlandı.", ["Number of times you were killed."]="Öldürüldüğünüz toplam sayı.",
    ["Death Effect"]="Ölüm Efekti", ["Away from Keyboard"]="Klavyeden Uzakta", ["Do not Disturb"]="Rahatsız Etmeyin",
    ["Defense Rating"]="Savunma Puanı", Deflect="Saptırma", DELETE="SİL", ["Deleting this mail will also destroy:"]="Bu postayı silerseniz şunlar da yok olur:",
    ["Use desktop gamma"]="Masaüstü Gamasını Kullan", Disguise="Kılık Değiştirme", ["Dishonorable Kills"]="Onursuz Öldürmeler",
    ["Donation Rewards"]="Bağış Ödülleri", About="Hakkında", ["Auto Preview"]="Otomatik Ön İzleme", ["Balance:"]="Bakiye:",
    ["Change Color"]="Rengi Değiştir", Claim="Al", ["Are you sure you want to hide the minimap shop button?"]="Mini haritadaki mağaza düğmesini gizlemek istediğinizden emin misiniz?",
    ["Time-limited offer"]="Süreli Teklif", ["Can't process payment."]="Ödeme işlenemedi.",
    ["You cannot receive this item. Your inventory may be full."]="Bu eşyayı alamıyorsunuz. Envanteriniz dolu olabilir.",
    ["You don't have enough tokens to claim this!"]="Bunu almak için yeterli jetonunuz yok!", ["Item is not available right now."]="Bu eşya şu anda alınamıyor.",
    ["Left-click to open."]="Açmak için sol tıklayın.", ["Hold alt and right-click to hide this button."]="Düğmeyi gizlemek için Alt tuşuyla sağ tıklayın.",
    ["Octo Shop"]="Octo Mağazası", ["Donation Information"]="Bağış Bilgileri", ["Dressing Room"]="Giyinme Odası",
    ["You feel sober again."]="Yeniden ayıldınız.", ["You feel tipsy.  Whee!"]="Hafif çakırkeyif hissediyorsunuz!",
    ["You feel drunk.  Woah!"]="Sarhoş hissediyorsunuz!", ["You feel completely smashed."]="Çok sarhoş hissediyorsunuz.",
    Normal="Normal", Hard="Zor", Elite="Seçkin", ["Your equipped items suffer a 10% durability loss."]="Kuşanılmış eşyalarınız %10 dayanıklılık kaybetti.",
    ["Left-click to open the radio."]="Radyoyu açmak için sol tıklayın.", Mute="Sesi Kapat", ["Tune In"]="Bağlan", ["Tune Out"]="Bağlantıyı Kes",
    ["Save Changes"]="Değişiklikleri Kaydet", Effects="Efektler", Border="Kenarlık", ["Border Color"]="Kenarlık Rengi",
    Icon="Simge", ["Icon Color"]="Simge Rengi", Empty="Boş", ["Empty Stable Slot"]="Boş Ahır Yuvası",
    ["Enable All Shader Effects"]="Tüm Gölgelendirici Efektlerini Aç", ["Enable All Sound"]="Tüm Sesleri Aç",
    ["Enable Ambience"]="Ortam Seslerini Aç", ["Enable Emote Sounds"]="İfade Seslerini Aç", ["Enable Error Speech"]="Hata Seslerini Aç",
    ["Enable Group Speech"]="Grup Konuşmalarını Aç", ["Enable Music"]="Müziği Aç", ["Enable Sound at Character"]="Sesi Karakter Konumundan Duy",
    ["Display Tips"]="İpuçlarını Göster", ["Enchant/Unlock Slot"]="Yuvayı Efsunla/Aç", ["Enclosed amount"]="Eklenen Tutar",
    Enchant="Efsunla", ["Entering Combat"]="Savaşa Giriliyor", ["Enter Battle"]="Savaşa Gir", ["Please enter code:"]="Lütfen kodu girin:",
    ["Equip Container"]="Çantayı Kuşan", ERROR="HATA", ["Cannot equip that with a two-handed weapon."]="Bu eşya iki elli silahla birlikte kuşanılamaz.",
    ["You are already in a guild."]="Zaten bir loncadasınız.", ["Only ammo can go there."]="Buraya yalnızca mühimmat konabilir.",
    ["You cannot sell a non-empty bag."]="Dolu bir çantayı satamazsınız.", ["Your bid increment is too small."]="Teklif artışınız çok düşük.",
    ["You cannot bid on your own auction."]="Kendi müzayedenize teklif veremezsiniz.", ["Bid accepted."]="Teklif kabul edildi.",
    ["There is already a higher bid on that item."]="Bu eşya için daha yüksek bir teklif var.", ["You must meet the min bid."]="En düşük teklif tutarına ulaşmalısınız.",
    ["Auction cancelled."]="Müzayede iptal edildi.", ["Auction created."]="Müzayede oluşturuldu.", ["You cannot auction a wrapped item."]="Paketlenmiş eşya müzayedeye konamaz.",
    ["You've reached your limit of bag slots!"]="Çanta yuvası sınırına ulaştınız!", ["That unit is not a banker!"]="Bu kişi bankacı değil!",
    ["Your bank is full"]="Bankanız dolu", ["That has already been used."]="Bu zaten kullanılmış.",
    ["You have to be standing to attack anything!"]="Saldırmak için ayakta olmalısınız!", ["You don't have the required rank for that item"]="Bu eşya için gereken rütbeye sahip değilsiniz",
    ["You don't have the required reputation for that item"]="Bu eşya için gereken itibara sahip değilsiniz",
    ["You aren't skilled enough to use that item."]="Bu eşyayı kullanmak için beceriniz yeterli değil.", ["Can't speak while shapeshifted."]="Biçim değiştirmişken konuşamazsınız.",
    ["You cannot use an item that is disarmed."]="Silahsızlandırılmış bir eşyayı kullanamazsınız.", ["Bags can't be wrapped."]="Çantalar paketlenemez.",
    ["Bound items can't be wrapped."]="Bağlı eşyalar paketlenemez.", ["Equipped items can't be wrapped."]="Kuşanılmış eşyalar paketlenemez.",
    ["Stackable items can't be wrapped."]="İstiflenebilir eşyalar paketlenemez.", ["Unique items can't be wrapped."]="Eşsiz eşyalar paketlenemez.",
    ["Wrapped items can't be wrapped."]="Zaten paketlenmiş eşyalar yeniden paketlenemez.", ["Hardcore characters cannot perform that action."]="Kalıcı ölüm modundaki karakterler bu işlemi yapamaz.",
    ["You can only whisper to members of your alliance."]="Yalnızca kendi ittifakınızdaki oyunculara fısıldayabilirsiniz.",
    ["Click on an item to feed to your pet"]="Evcil hayvanınıza vermek istediğiniz yiyeceğe tıklayın", ["You can only do that with empty bags."]="Bunu yalnızca boş çantalarla yapabilirsiniz.",
    ["You're not mounted!"]="Binekte değilsiniz!", ["You can't drop a soulbound item."]="Ruha bağlı bir eşyayı bırakamazsınız.",
    ["You have requested a duel."]="Düello isteği gönderdiniz.", ["Unable to change dungeon difficulty"]="Zindan zorluğu değiştirilemiyor",
    ["You can't eat while moving."]="Hareket ederken yemek yiyemezsiniz.", ["Change back to your normal form first!"]="Önce normal biçiminize dönün!",
    ["That item is currently being traded"]="Bu eşya şu anda takas ediliyor", ["You feel exhausted."]="Bitkin hissediyorsunuz.",
    ["You feel normal."]="Normal hissediyorsunuz.", ["You feel rested."]="Dinlenmiş hissediyorsunuz.", ["You feel tired."]="Yorgun hissediyorsunuz.",
    ["You feel well rested."]="Çok iyi dinlenmiş hissediyorsunuz.", Resisted="Direnildi", ["You are too full to eat more now."]="Şu anda daha fazla yemek yiyemeyecek kadar toksunuz.",
    ["Friend lookup database error."]="Arkadaş arama veritabanı hatası.", ["Unknown friend response from server."]="Sunucudan bilinmeyen arkadaş yanıtı geldi.",
    ["You don't have room for any more friends."]="Arkadaş listenizde yer kalmadı.", ["Player not found."]="Oyuncu bulunamadı.",
    ["You can't put yourself on your friend list."]="Kendinizi arkadaş listenize ekleyemezsiniz.", ["Friends must be part of your alliance."]="Arkadaşlarınız kendi ittifakınızdan olmalıdır.",
    ["Your group has been disbanded."]="Grubunuz dağıtıldı.", ["Your party is full."]="Grubunuz dolu.", ["Your group is too big to join that battleground"]="Grubunuz bu savaş alanına katılmak için çok büyük",
    ["Your guild already has an emblem!"]="Loncanızın zaten bir arması var!", ["That's not an emblem vendor!"]="Bu kişi arma satıcısı değil!",
    ["Invalid Guild Emblem colors."]="Geçersiz lonca arması renkleri.", ["Are you sure you want to permanently abandon your pet?"]="Evcil hayvanınızı kalıcı olarak bırakmak istediğinizden emin misiniz?",
}
for source, translation in pairs(additions) do W.LocalText[source] = translation end

-- Explicitly reviewed templates. Captured names are copied verbatim by default.
local templates = {
    {"%.2f days", "$1 gün"}, {"%.2f hrs", "$1 saat"}, {"%.2f min", "$1 dakika"}, {"%.2f sec", "$1 saniye"},
    {"%.3g min cast", "$1 dakikada yapılır"}, {"%.3g sec cast", "$1 saniyede yapılır"},
    {"%.3g min cooldown", "$1 dakika bekleme süresi"}, {"%.3g sec cooldown", "$1 saniye bekleme süresi"},
    {"%.2f%% chance to block", "%$1 blok şansı"}, {"%.2f%% chance to crit", "%$1 kritik vuruş şansı"},
    {"%.2f%% chance to dodge", "%$1 sıyrılma şansı"}, {"%.2f%% chance to parry", "%$1 savuşturma şansı"},
    {"(%.1f damage per second)", "(saniyede $1 hasar)"}, {"%d - %d Damage", "$1 - $2 Hasar"},
    {"%d Armor", "$1 Zırh"}, {"%d Block", "$1 Blok"}, {"Speed %.2f", "Hız $1"},
    {"Requires Level %d", "Gerekli Seviye $1"}, {"Requires %s (%d)", "Gereksinim: $1 ($2)", true},
    {"Requires %s", "Gereksinim: $1", true}, {"Durability %d / %d", "Dayanıklılık $1 / $2"},
    {"Rank %d", "Seviye $1"}, {"Level %d", "Seviye $1"}, {"Page %d", "Sayfa $1"},
    {"Quests: %d/%d", "Görevler: $1/$2"}, {"Health %d / %d", "Sağlık $1 / $2"},
    {"Mana %d / %d", "Mana $1 / $2"}, {"Rage %d / %d", "Öfke $1 / $2"}, {"Energy %d / %d", "Enerji $1 / $2"},
    {"%d Charges", "$1 Kullanım"}, {"%d Charge", "$1 Kullanım"},
    {"%d sec cast", "$1 saniyede yapılır"}, {"%d min cast", "$1 dakikada yapılır"},
    {"%d sec cooldown", "$1 saniye bekleme süresi"}, {"%d min cooldown", "$1 dakika bekleme süresi"},
    {"%d yd range", "$1 yarda menzil"}, {"%d-%d yd range", "$1-$2 yarda menzil"},
    {"%d Mana", "$1 Mana"}, {"%d Rage", "$1 Öfke"}, {"%d Energy", "$1 Enerji"},
    {"Abandon \"%s\"?", "\"$1\" görevini bırakmak istiyor musunuz?", true},
    {"Delete %s?", "$1 silinsin mi?", true}, {"Are you sure you want to delete %s?", "$1 silinsin mi?", true},
    {"Are you sure you want to ignore %s?", "$1 adlı oyuncuyu engellemek istediğinizden emin misiniz?"},
    {"Are you sure you want to remove %s from your friends list?", "$1 adlı oyuncuyu arkadaş listenizden çıkarmak istediğinizden emin misiniz?"},
    {"%s has invited you to join a group.", "$1 sizi bir gruba davet etti."},
    {"%s has invited you to join a guild.", "$1 sizi bir loncaya davet etti."},
    {"Made by %s", "$1 tarafından üretildi"}, {"<Made by %s>", "<$1 tarafından üretildi>"},
}

local indexed = {}
local function prefix(text)
    local _, _, first = string.find(text, "^(%a+)")
    return first or "@"
end
for _, entry in ipairs(templates) do
    local source, pattern, index, count = entry[1], "^", 1, 0
    while index <= string.len(source) do
        if string.sub(source, index, index) == "%" then
            if string.sub(source, index + 1, index + 1) == "%" then pattern = pattern .. "%%"; index = index + 2
            else
                local start, ending, kind = string.find(source, "%%[-+%d%.]*([sdifg])", index)
                if start ~= index then error("Invalid UI template: " .. source) end
                count = count + 1
                pattern = pattern .. (kind == "s" and "(.+)" or "([%d%.,%-]+)")
                index = ending + 1
            end
        else pattern = pattern .. W.Escape(string.sub(source, index, index)); index = index + 1 end
    end
    local key = prefix(source)
    if not indexed[key] then indexed[key] = {} end
    table.insert(indexed[key], {pattern .. "$", entry[2], entry[3], count})
end

function W.TemplateTranslation(source)
    local key = prefix(source)
    for _, candidates in ipairs({key ~= "@" and indexed[key] or false, indexed["@"] or false}) do
      if candidates then for _, entry in ipairs(candidates) do
        local values = W.Capture(string.find(source, entry[1]))
        if values[1] then
            return (string.gsub(entry[2], "%$(%d+)", function(number)
                local value = values[tonumber(number) + 2] or ""
                if entry[3] then value = W.LocalText[value] or (W.QuestTitleTranslation and W.QuestTitleTranslation(value)) or value end
                return value
            end))
        end
      end end
    end
end
