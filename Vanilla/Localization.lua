-- Reviewed additions for Vanilla and the OctoWoW client. Source API values stay English.
local W = WoWTRV
W.LocalText = {
    ["Quest Log"]="Görev Günlüğü", Spellbook="Büyü Kitabı", ["Spell Book"]="Büyü Kitabı",
    ["Track Quest"]="Görevi Takip Et", ["Untrack Quest"]="Takibi Bırak", All="Tümü",
    ["Share Quest"]="Görevi Paylaş", ["Abandon Quest"]="Görevi Bırak", Exit="Çıkış", Close="Kapat",
    Accept="Kabul Et", Decline="Reddet", Continue="Devam", Complete="Tamamla",
    ["Complete Quest"]="Görevi Tamamla", Goodbye="Hoşça Kal", Description="Açıklama",
    Objectives="Hedefler", Rewards="Ödüller", ["Quest Objectives"]="Görev Hedefleri",
    ["Current Quests"]="Mevcut Görevler", ["Available Quests"]="Alınabilir Görevler",
    ["Required Items"]="Gerekli Eşyalar", ["You will receive:"]="Alacağınız ödüller:",
    ["Choose your reward:"]="Ödülünüzü seçin:", ["Choose one of these rewards:"]="Bu ödüllerden birini seçin:",
    ["Class Skills"]="Sınıf Becerileri", ["Weapon Skills"]="Silah Becerileri",
    ["Armor Proficiencies"]="Zırh Yetkinlikleri", Languages="Diller", Professions="Meslekler",
    ["Secondary Skills"]="İkincil Beceriler", ["Secondary Professions"]="İkincil Meslekler",
    Arms="Silahlar", Fury="Hiddet", Protection="Koruma", Axes="Baltalar", Axe="Balta",
    Bows="Yaylar", Bow="Yay", Defense="Savunma", Swords="Kılıçlar", Sword="Kılıç",
    ["Two-Handed Axes"]="İki Elli Baltalar", ["Two-Handed Swords"]="İki Elli Kılıçlar",
    ["Two-Handed Maces"]="İki Elli Topuzlar", Maces="Topuzlar", Mace="Topuz", Daggers="Hançerler",
    Dagger="Hançer", Staves="Asalar", Staff="Asa", Wands="Değnekler", Wand="Değnek",
    Guns="Tüfekler", Gun="Tüfek", Crossbows="Arbaletler", Crossbow="Arbalet", Polearms="Gönderli Silahlar",
    ["Fist Weapons"]="Yumruk Silahları", Thrown="Fırlatma", Unarmed="Silahsız Dövüş",
    Cloth="Kumaş", Leather="Deri", Mail="Zincir Zırh", Plate="Plaka Zırh", Shield="Kalkan", Shields="Kalkanlar",
    ["One-Hand"]="Tek El", ["Two-Hand"]="İki El", ["Main Hand"]="Ana El", ["Off Hand"]="Diğer El",
    ["Held In Off-hand"]="Diğer Elde Tutulur", Head="Baş", Neck="Boyun", Shoulder="Omuz",
    Back="Sırt", Chest="Göğüs", Shirt="Gömlek", Tabard="Arma", Wrist="Bilek", Hands="Eller",
    Waist="Bel", Legs="Bacaklar", Feet="Ayaklar", Finger="Parmak", Trinket="Aksesuar", Ranged="Menzilli",
    ["Class Abilities"]="Sınıf Yetenekleri", Abilities="Yetenekler", General="Genel",
    ["Hearthstone"]="Dönüş Taşı", ["Tough Jerky"]="Sert Kurutulmuş Et", ["Blood Fury"]="Kan Hiddeti",
    Attack="Saldırı", Dodge="Sıyrılma", ["Axe Specialization"]="Balta Uzmanlığı",
    Exhaustion="Bitkinlik", Block="Blok", Hardiness="Dirençlilik", Command="Hükmetme",
    ["Level One Lunatic"]="Birinci Seviye Delisi", ["Boring Adventure"]="Sıkıcı Macera",
    ["Path of the Brewmaster"]="Bira Ustasının Yolu", ["Shoot Bow"]="Yay Atışı",
    ["Shoot Crossbow"]="Arbalet Atışı", ["Shoot Gun"]="Tüfek Atışı", Shoot="Atış",
    Racial="Irksal", ["Racial Passive"]="Irksal Pasif", Passive="Pasif", Challenge="Meydan Okuma",
    Prev="Önceki", Previous="Önceki", Next="Sonraki", Health="Sağlık", Mana="Mana", Rage="Öfke", Energy="Enerji",
    ["Valley of Trials"]="Sınamalar Vadisi", ["Valley of Honor"]="Onur Vadisi", ["Valley of Strength"]="Güç Vadisi",
    ["Valley of Wisdom"]="Bilgelik Vadisi", ["Valley of Spirits"]="Ruhlar Vadisi", ["The Den"]="İn",
    ["Northshire Valley"]="Kuzeykent Vadisi", ["Northshire Abbey"]="Kuzeykent Manastırı",
    ["Elwynn Forest"]="Elwynn Ormanı", ["Tirisfal Glades"]="Tirisfal Açıklıkları", ["Silverpine Forest"]="Gümüşçam Ormanı",
    ["Dun Morogh"]="Dun Morogh", ["Durotar"]="Durotar", ["Mulgore"]="Mulgore", ["Teldrassil"]="Teldrassil",
    ["The Barrens"]="Çorak Topraklar", Westfall="Batı Diyarları", ["Redridge Mountains"]="Kızıl Sırt Dağları",
    Duskwood="Alacakaranlık Ormanı", Darkshore="Karanlık Kıyı", Ashenvale="Kül Vadisi",
    ["Stonetalon Mountains"]="Taşpençe Dağları", ["Thousand Needles"]="Bin İğne", Wetlands="Sulak Alanlar",
    ["Hillsbrad Foothills"]="Hillsbrad Etekleri", ["Arathi Highlands"]="Arathi Yaylaları",
    ["Stranglethorn Vale"]="Dikenboğaz Vadisi", ["Alterac Mountains"]="Alterac Dağları",
    ["The Hinterlands"]="İç Topraklar", ["Western Plaguelands"]="Batı Veba Toprakları",
    ["Eastern Plaguelands"]="Doğu Veba Toprakları", ["Burning Steppes"]="Yanan Bozkırlar",
    ["Searing Gorge"]="Kavurucu Geçit", ["Swamp of Sorrows"]="Keder Bataklığı",
    ["Blasted Lands"]="Patlamış Topraklar", ["Badlands"]="Kıraç Topraklar", Winterspring="Kışpınarı",
    ["Moonglade"]="Ay Açıklığı", Felwood="Fel Ormanı", ["Un'Goro Crater"]="Un'Goro Krateri",
    ["Deadwind Pass"]="Ölü Rüzgâr Geçidi", ["Dustwallow Marsh"]="Tozbataklığı",
    ["Thunder Bluff"]="Gök Gürültüsü Tepesi", ["Stormwind City"]="Fırtınayel Şehri",
    ["Stormwind"]="Fırtınayel", Ironforge="Demirdövüm", Undercity="Yeraltı Şehri",
    ["The Deadmines"]="Ölüm Madenleri", ["Wailing Caverns"]="Ağlayan Mağaralar",
    ["Ragefire Chasm"]="Öfke Ateşi Uçurumu", ["Shadowfang Keep"]="Gölgediş Kalesi",
    ["Scarlet Monastery"]="Kızıl Manastır", ["Blackfathom Deeps"]="Kara Kulaç Derinlikleri",
    ["Blackrock Depths"]="Karataş Derinlikleri", ["Blackrock Spire"]="Karataş Kulesi",
    ["Dire Maul"]="Uğursuz Çekiç", ["Molten Core"]="Erimiş Çekirdek", ["Blackwing Lair"]="Kara Kanat İni",
    Backpack="Sırt Çantası", Keyring="Anahtarlık", Character="Karakter", Pet="Evcil Hayvan",
    Reputation="İtibar", Skills="Beceriler", Honor="Onur", ["Main Menu"]="Ana Menü",
    ["Video Options"]="Görüntü Ayarları", ["Sound Options"]="Ses Ayarları", ["Interface Options"]="Arayüz Ayarları",
    ["Key Bindings"]="Tuş Atamaları", Video="Görüntü", Sound="Ses", Interface="Arayüz", Keybindings="Tuş Atamaları",
    Macros="Makrolar", Logout="Çıkış Yap", ["Log Out"]="Çıkış Yap", ["Exit Game"]="Oyundan Çık", ["Return to Game"]="Oyuna Dön",
    Yes="Evet", No="Hayır", Okay="Tamam", OK="Tamam", Cancel="İptal", Apply="Uygula", Reset="Sıfırla",
    Defaults="Varsayılanlar", Default="Varsayılan", Done="Bitti", Help="Yardım", Options="Ayarlar",
    Enable="Etkinleştir", Disable="Devre Dışı Bırak", Enabled="Etkin", Disabled="Devre Dışı",
    ["Game Options"]="Oyun Ayarları", ["User Interface"]="Kullanıcı Arayüzü", Controls="Kontroller", Display="Görüntü",
    ["Action Bars"]="Eylem Çubukları", ["Combat Text"]="Savaş Yazıları", ["Combat Log"]="Savaş Kaydı",
    ["World Map"]="Dünya Haritası", Map="Harita", Continent="Kıta", Zone="Bölge", ["Zoom Out"]="Uzaklaştır",
    Strength="Kuvvet", Agility="Çeviklik", Stamina="Dayanıklılık", Intellect="Zekâ", Spirit="Ruh",
    Armor="Zırh", Damage="Hasar", Speed="Hız", ["Attack Power"]="Saldırı Gücü", ["Spell Power"]="Büyü Gücü",
    ["Critical Strike"]="Kritik Vuruş", ["Critical Strike Chance"]="Kritik Vuruş Şansı", ["Hit Chance"]="İsabet Şansı",
    ["Base Stats"]="Temel Nitelikler", ["Melee Attack"]="Yakın Dövüş", ["Ranged Attack"]="Menzilli Saldırı",
    Resistances="Dirençler", Arcane="Gizem", Fire="Ateş", Frost="Buz", Nature="Doğa", Shadow="Gölge", Holy="Kutsal",
    Durability="Dayanıklılık", Soulbound="Ruha Bağlı", Unique="Eşsiz", ["Quest Item"]="Görev Eşyası",
    ["Binds when picked up"]="Alındığında bağlanır", ["Binds when equipped"]="Kuşanıldığında bağlanır",
    ["Binds when used"]="Kullanıldığında bağlanır", ["Already Known"]="Zaten Biliniyor", ["Sell Price:"]="Satış Fiyatı:",
    Merchant="Satıcı", Buyback="Geri Satın Al", ["Repair All"]="Tümünü Onar", ["Repair Cost"]="Onarım Bedeli",
    Bank="Banka", ["Buy Bank Slot"]="Banka Yuvası Al", Trade="Takas", ["Trade Items"]="Takas Eşyaları",
    ["Will not be traded"]="Takas edilmeyecek", Auction="Müzayede", Auctions="Müzayedeler", Bids="Teklifler",
    Browse="Göz At", Search="Ara", Bid="Teklif Ver", Buyout="Hemen Al", Seller="Satıcı", ["Current Bid"]="Mevcut Teklif",
    ["Time Left"]="Kalan Süre", ["Create Auction"]="Müzayede Oluştur", ["Cancel Auction"]="Müzayedeyi İptal Et",
    Inbox="Gelen Kutusu", ["Send Mail"]="Posta Gönder", Subject="Konu", Send="Gönder", Return="Geri Gönder",
    Delete="Sil", ["Open All"]="Tümünü Aç", ["Take Attachments"]="Ekleri Al", ["To:"]="Alıcı:", ["Subject:"]="Konu:",
    Train="Öğren", Available="Öğrenilebilir", Unavailable="Öğrenilemez", ["Already Known"]="Zaten Biliniyor",
    ["Required level:"]="Gerekli seviye:", ["Training Cost:"]="Eğitim Bedeli:", Cost="Bedel", Reagents="Malzemeler",
    Create="Üret", ["Create All"]="Tümünü Üret", ["Required Tools:"]="Gerekli Aletler:", ["Requires:"]="Gereksinimler:",
    Alchemy="Simya", Blacksmithing="Demircilik", Enchanting="Efsunculuk", Engineering="Mühendislik",
    Herbalism="Bitkicilik", Leatherworking="Dericilik", Mining="Madencilik", Skinning="Deri Yüzme", Tailoring="Terzilik",
    Cooking="Aşçılık", Fishing="Balıkçılık", ["First Aid"]="İlk Yardım", Riding="Binicilik", Survival="Hayatta Kalma",
    Apprentice="Çırak", Journeyman="Kalfa", Expert="Uzman", Artisan="Zanaatkâr", Master="Usta",
    ["Heroic Strike"]="Kahramanca Vuruş", ["Battle Stance"]="Savaş Duruşu", ["Defensive Stance"]="Savunma Duruşu",
    ["Berserker Stance"]="Çılgın Duruş", Charge="Hücum", Rend="Yırtma", Hamstring="Sakatlama", Execute="İnfaz",
    ["Battle Shout"]="Savaş Narası", ["Demoralizing Shout"]="Yıldırıcı Nara", ["Thunder Clap"]="Gök Gürültüsü Darbesi",
    ["Sunder Armor"]="Zırh Parçalama", Taunt="Kışkırtma", Revenge="İntikam", Overpower="Ezme", Cleave="Yarma",
    ["Mocking Blow"]="Alaycı Darbe", Retaliation="Misilleme", ["Shield Bash"]="Kalkan Darbesi", ["Shield Block"]="Kalkan Bloğu",
    ["Shield Wall"]="Kalkan Duvarı", ["Shield Slam"]="Kalkan Vuruşu", ["Disarm"]="Silahsızlandırma",
    Intercept="Önleme", ["Berserker Rage"]="Çılgın Öfkesi", Whirlwind="Kasırga", ["Mortal Strike"]="Ölümcül Vuruş",
    Bloodthirst="Kan Susamışlığı", ["Sweeping Strikes"]="Süpürücü Vuruşlar", Pummel="Yumruklama",
    ["Intimidating Shout"]="Korkutucu Nara", ["Challenging Shout"]="Meydan Okuma Narası", Recklessness="Pervasızlık",
    ["Last Stand"]="Son Direniş", ["Piercing Howl"]="Delici Uluma", ["Death Wish"]="Ölüm Arzusu", Bloodrage="Kan Öfkesi",
    Fireball="Ateş Topu", Frostbolt="Buz Oku", ["Arcane Missiles"]="Gizemli Füzeler", ["Fire Blast"]="Ateş Patlaması",
    ["Frost Nova"]="Buz Novası", ["Cone of Cold"]="Soğuk Konisi", Blizzard="Tipi", ["Arcane Explosion"]="Gizem Patlaması",
    ["Frost Armor"]="Buz Zırhı", ["Ice Armor"]="Buz Zırhı", ["Mage Armor"]="Büyücü Zırhı", ["Mana Shield"]="Mana Kalkanı",
    ["Arcane Intellect"]="Gizemli Zekâ", ["Arcane Brilliance"]="Gizemli Deha", ["Conjure Water"]="Su Yaratma",
    ["Conjure Food"]="Yiyecek Yaratma", Blink="Göz Kırpma", Polymorph="Dönüştürme", Counterspell="Karşı Büyü",
    ["Remove Lesser Curse"]="Zayıf Laneti Kaldır", ["Slow Fall"]="Yavaş Düşüş", Evocation="Mana Çağrısı",
    ["Ice Block"]="Buz Bloğu", ["Ice Barrier"]="Buz Bariyeri", Scorch="Kavurma", Flamestrike="Alev Darbesi", Pyroblast="Alev Patlaması",
    Smite="Çarpma", ["Lesser Heal"]="Küçük İyileştirme", Heal="İyileştirme", ["Greater Heal"]="Büyük İyileştirme",
    ["Flash Heal"]="Ani İyileştirme", Renew="Yenileme", ["Power Word: Shield"]="Güç Sözcüğü: Kalkan",
    ["Power Word: Fortitude"]="Güç Sözcüğü: Metanet", ["Shadow Word: Pain"]="Gölge Sözcüğü: Acı",
    ["Mind Blast"]="Zihin Patlaması", ["Mind Flay"]="Zihin Yüzme", ["Psychic Scream"]="Psişik Çığlık",
    ["Holy Fire"]="Kutsal Ateş", ["Holy Nova"]="Kutsal Nova", Resurrection="Diriltme", ["Dispel Magic"]="Büyü Dağıtma",
    ["Cure Disease"]="Hastalık İyileştirme", ["Abolish Disease"]="Hastalık Giderme", ["Mind Control"]="Zihin Kontrolü",
    ["Prayer of Healing"]="İyileştirme Duası", ["Prayer of Fortitude"]="Metanet Duası", Shadowform="Gölge Biçimi",
    ["Shadow Bolt"]="Gölge Oku", Immolate="Kurban Etme", Corruption="Yozlaşma", ["Curse of Agony"]="Istırap Laneti",
    ["Curse of Weakness"]="Zayıflık Laneti", ["Curse of Recklessness"]="Pervasızlık Laneti", Fear="Korku",
    ["Drain Life"]="Yaşam Sömürme", ["Drain Soul"]="Ruh Sömürme", ["Drain Mana"]="Mana Sömürme", ["Life Tap"]="Yaşam Aktarımı",
    ["Demon Skin"]="İblis Derisi", ["Demon Armor"]="İblis Zırhı", ["Summon Imp"]="İmp Çağırma",
    ["Summon Voidwalker"]="Hiçlik Gezgini Çağırma", ["Summon Succubus"]="Sukkubus Çağırma", ["Summon Felhunter"]="Fel Avcısı Çağırma",
    ["Create Healthstone"]="Sağlık Taşı Yaratma", ["Create Soulstone"]="Ruh Taşı Yaratma", ["Ritual of Summoning"]="Çağırma Ritüeli",
    ["Rain of Fire"]="Ateş Yağmuru", Hellfire="Cehennem Ateşi", Banish="Sürgün", ["Death Coil"]="Ölüm Sarmalı",
    ["Sinister Strike"]="Uğursuz Vuruş", Eviscerate="İç Deşme", Stealth="Gizlilik", Backstab="Arkadan Bıçaklama",
    ["Slice and Dice"]="Dilimleme", Gouge="Oyma", Kick="Tekme", Evasion="Kaçınma", Sprint="Sürat Koşusu",
    Sap="Bayıltma", ["Pick Pocket"]="Yankesicilik", ["Pick Lock"]="Kilit Açma", ["Cheap Shot"]="Bel Altı Vuruş",
    ["Kidney Shot"]="Böbrek Vuruşu", Garrote="Boğazlama", Rupture="Yırtılma", Ambush="Pusu", Vanish="Kaybolma",
    Blind="Kör Etme", ["Distract"]="Dikkat Dağıtma", ["Feint"]="Aldatmaca", ["Detect Traps"]="Tuzak Algılama",
    ["Auto Shot"]="Otomatik Atış", ["Arcane Shot"]="Gizemli Atış", ["Serpent Sting"]="Yılan Sokması",
    ["Concussive Shot"]="Sarsıcı Atış", ["Multi-Shot"]="Çoklu Atış", ["Aimed Shot"]="Nişanlı Atış",
    ["Raptor Strike"]="Yırtıcı Darbesi", ["Mongoose Bite"]="Firavun Faresi Isırığı", ["Wing Clip"]="Kanat Kırpma",
    ["Hunter's Mark"]="Avcı İşareti", ["Aspect of the Hawk"]="Şahin Sureti", ["Aspect of the Monkey"]="Maymun Sureti",
    ["Aspect of the Cheetah"]="Çita Sureti", ["Aspect of the Pack"]="Sürü Sureti", ["Tame Beast"]="Yaratık Evcilleştirme",
    ["Call Pet"]="Evcil Hayvan Çağırma", ["Dismiss Pet"]="Evcil Hayvanı Gönder", ["Revive Pet"]="Evcil Hayvanı Dirilt",
    ["Feed Pet"]="Evcil Hayvanı Besle", ["Mend Pet"]="Evcil Hayvanı İyileştir", ["Feign Death"]="Ölü Taklidi",
    ["Freezing Trap"]="Dondurucu Tuzak", ["Frost Trap"]="Buz Tuzağı", ["Explosive Trap"]="Patlayıcı Tuzak",
    ["Lightning Bolt"]="Yıldırım Oku", ["Chain Lightning"]="Zincirleme Yıldırım", ["Earth Shock"]="Toprak Şoku",
    ["Flame Shock"]="Alev Şoku", ["Frost Shock"]="Buz Şoku", ["Lightning Shield"]="Yıldırım Kalkanı",
    ["Healing Wave"]="İyileştirme Dalgası", ["Lesser Healing Wave"]="Küçük İyileştirme Dalgası", ["Chain Heal"]="Zincirleme İyileştirme",
    ["Rockbiter Weapon"]="Taş Isıran Silah", ["Flametongue Weapon"]="Alev Dilli Silah", ["Windfury Weapon"]="Rüzgâr Hiddeti Silahı",
    ["Ghost Wolf"]="Hayalet Kurt", ["Astral Recall"]="Astral Dönüş", Purge="Arındırma", Reincarnation="Yeniden Doğuş",
    ["Holy Light"]="Kutsal Işık", ["Flash of Light"]="Işık Parlaması", ["Seal of Righteousness"]="Doğruluk Mührü",
    ["Seal of the Crusader"]="Haçlı Mührü", ["Seal of Command"]="Hükmetme Mührü", Judgement="Yargı",
    ["Blessing of Might"]="Kudret Kutsaması", ["Blessing of Wisdom"]="Bilgelik Kutsaması", ["Blessing of Kings"]="Kralların Kutsaması",
    ["Blessing of Protection"]="Koruma Kutsaması", ["Blessing of Freedom"]="Özgürlük Kutsaması", ["Divine Shield"]="İlahi Kalkan",
    ["Divine Protection"]="İlahi Koruma", ["Lay on Hands"]="Ellerle Şifa", ["Hammer of Justice"]="Adalet Çekici",
    ["Devotion Aura"]="Adanmışlık Aurası", ["Retribution Aura"]="Misilleme Aurası", Consecration="Kutsama", Redemption="Diriliş",
    ["Mark of the Wild"]="Vahşiliğin İşareti", Wrath="Gazap", Moonfire="Ay Ateşi", ["Healing Touch"]="İyileştirici Dokunuş",
    Rejuvenation="Gençleşme", Regrowth="Yeniden Büyüme", Thorns="Dikenler", ["Entangling Roots"]="Dolaşan Kökler",
    ["Bear Form"]="Ayı Biçimi", ["Cat Form"]="Kedi Biçimi", ["Travel Form"]="Seyahat Biçimi", ["Aquatic Form"]="Su Biçimi",
    ["Dire Bear Form"]="Ulu Ayı Biçimi", Maul="Parçalama", Swipe="Pençe Savuruşu", Growl="Hırlama", Claw="Pençeleme",
    Rake="Tırmalama", Rip="Deşme", ["Ferocious Bite"]="Vahşi Isırık", Prowl="Sinsice Yaklaşma", Dash="Atılma",
    ["Bash"]="Sersemletici Darbe", Enrage="Öfkelenme", Rebirth="Yeniden Doğuş", Innervate="Canlandırma",
    ["Gift of the Wild"]="Vahşiliğin Armağanı", ["Cure Poison"]="Zehir İyileştirme", ["Abolish Poison"]="Zehir Giderme",
    ["War Stomp"]="Savaş Tepinmesi", Berserking="Çılgına Dönme", Regeneration="Yenilenme", ["Will of the Forsaken"]="Terk Edilmişlerin İradesi",
    Cannibalize="Yamyamlık", ["Shadowmeld"]="Gölgeye Karışma", Quickness="Çabukluk", ["Escape Artist"]="Kaçış Ustası",
    Stoneform="Taş Biçimi", Perception="Algılama", Diplomacy="Diplomasi", ["Sword Specialization"]="Kılıç Uzmanlığı",
    ["Mace Specialization"]="Topuz Uzmanlığı", ["Bow Specialization"]="Yay Uzmanlığı", ["Gun Specialization"]="Tüfek Uzmanlığı",
    ["Nature Resistance"]="Doğa Direnci", ["Shadow Resistance"]="Gölge Direnci", ["Frost Resistance"]="Buz Direnci",
    ["Arcane Resistance"]="Gizem Direnci", ["Fire Resistance"]="Ateş Direnci", ["Beast Slaying"]="Yaratık Avcılığı",
    Endurance="Dayanıklılık", Cultivation="Yetiştiricilik", ["Expansive Mind"]="Geniş Zihin", ["The Human Spirit"]="İnsan Ruhu",
}

local function plain(text)
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "[\r\n]", " ")
    return W.Trim((string.gsub(text, "%s+", " ")))
end

function W.DisplayTranslation(text, numbers)
    if type(text) ~= "string" or text == "" then return nil end
    local source = plain(text)
    local exact = W.LocalText[source]
    if exact then return exact end
    if string.sub(source, -1) == ":" then
        local label = W.LocalText[W.Trim(string.sub(source, 1, -2))]
        if label then return label .. ":" end
    end
    local _, _, place, tail = string.find(source, "^Use: Returns you to (.-)%. Speak to an Innkeeper in a different place to change your home location%.(.*)$")
    if place then
        local result = "Kullan: Sizi " .. (W.LocalText[place] or place) .. " konumuna geri götürür. Dönüş konumunuzu değiştirmek için başka bir yerdeki hancıyla konuşun."
        local _, _, minutes = string.find(tail, "(%d+) Min Cooldown")
        if minutes then result = result .. " (" .. minutes .. " dakika bekleme süresi)" end
        return result
    end
    local _, _, power, magic, duration, penalty, healDuration = string.find(source, "^Increases attack power by ([%d,.]+) and damage done by magical spells and effects by up to ([%d,.]+) for ([%d,.]+) sec%. Reduces healing effects on you by ([%d,.]+)%% for ([%d,.]+) sec%.$")
    if power then return "Saldırı gücünü " .. power .. ", büyü ve büyülü etkilerin verdiği hasarı " .. magic .. " kadar " .. duration .. " saniyeliğine artırır. Üzerinizdeki iyileştirme etkilerini " .. healDuration .. " saniyeliğine %" .. penalty .. " azaltır." end
    for _, pair in ipairs({{"Health", "Sağlık"}, {"Mana", "Mana"}, {"Rage", "Öfke"}, {"Energy", "Enerji"}, {"XP", "Deneyim"}, {"Quests:", "Görevler:"}, {"Page", "Sayfa"}, {"Rank", "Seviye"}, {"Level", "Seviye"}, {"Requires Level", "Gerekli Seviye"}, {"Durability", "Dayanıklılık"}, {"Armor", "Zırh"}, {"Damage", "Hasar"}, {"Speed", "Hız"}}) do
        local _, _, value = string.find(source, "^" .. W.Escape(pair[1]) .. " ([%d%.,%/%s%-]+)$")
        if value then return pair[2] .. " " .. value end
    end
    local _, _, amount, stat = string.find(source, "^(%+?[%d,%.]+) (.+)$")
    if amount and W.LocalText[stat] then return amount .. " " .. W.LocalText[stat] end
    for _, pair in ipairs({{"Requires ", "Gereksinim: "}, {"Use: ", "Kullan: "}, {"Equip: ", "Kuşan: "}}) do
        if string.sub(source, 1, string.len(pair[1])) == pair[1] then
            local body = string.sub(source, string.len(pair[1]) + 1)
            if W.LocalText[body] then return pair[2] .. W.LocalText[body] end
        end
    end
    local translation = W.TemplateTranslation and W.TemplateTranslation(source)
    if translation then return translation end
    translation = W.FindTranslation("tooltips", text, numbers)
    -- A record equal to its source is not evidence of Turkish coverage.
    if translation and plain(translation) ~= source then return translation end
    return nil
end

function W.RecordUntranslated(module, text)
    if type(text) ~= "string" then return end
    local source = plain(text)
    if string.len(source) < 3 or not string.find(source, "%a") or string.find(source, "|H", 1, true) then return end
    if W.LocalText[source] then return end -- Includes proper geographic names intentionally retained.
    W.Missing(module, W.Hash(W.Normalize(source, true)), source)
end
