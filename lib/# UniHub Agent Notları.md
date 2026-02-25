# UniHub Agent Notları

## Amaç
Tekrarlı anlatımı önlemek, isteklerini ve kararları tek bir yerde toplamak; veri tabanı şemasını, ürün gereksinimlerini ve yapılacaklar listesini sürdürmek.

## Veri Tabanı (Supabase / PostgreSQL)
- events
  - id (int8, PK)
  - club_id (int8, FK -> clubs.id)
  - title (text)
  - description (text)
  - location (text)
  - start_time (timestamp)  ← geçmiş tarih girilemez
  - created_at (timestamp)
- event_speakers
  - id (int8, PK)
  - event_id (int8, FK -> events.id)
  - full_name (text)
  - linkedin_url (text)
  - bio (text)
- clubs (özet)
  - id, name, short_name, description, category, university_id
  - main_color (hex), logo_path, banner_path, status
- profiles (özet)
  - id, email, first_name, last_name, university_id, faculty_id, department_id, …  

## Ürün Gereksinimleri
- Etkinlikler
  - Bir etkinliğin birden çok konuşmacısı olabilir (one-to-many).
  - Join ile tek sorguda çekim: `.from('events').select('*, event_speakers(*)')`.
  - Geçmiş tarihli etkinlik yayınlanamaz (UI + sunucu doğrulama).
- Kulüp Yönetimi (mobil)
  - Kulüp bilgileri: isim, açıklama, kategori, kısaltma, renk (hex), logo, banner değiştirilebilir.
  - Üye rolleri değiştirilebilir (Başkan/Yönetici/Üye), modal diyalog ile.
- Görsel
  - Top bar: solda UniHub, ortada aktif sayfa başlığı.
  - Sponsor kartları: banner üzerinde hafif koyu gradient; metin beyaz ve okunabilir.
  - Profil sekmesindeki gereksiz geri tuşu kaldırılmalı.
- Depolama
  - Logo ve banner Supabase Storage “clubs” bucket’ında tutulur.

## Yapılacaklar (To‑Do)
- [ ] Etkinliklerin gösterimi çalışmıyor
  - Notlar: join verilerini tek formatta kullan; boş veri ve RLS olasılığı için hata yakalamaları ekle; örnek veri ile test et.
  - Plan: EventsDiscoveryTab ve ClubEventsTab’te tek tip EventModel; boş konuşmacı listesini güvenli işle.
- [ ] Etkinlik yayınlama hatası
  - Notlar: start_time doğrulaması UI’da ve sunucu tarafında; insert sonrası id döndürme; konuşmacı ekleme toplu insert.
  - Plan: form doğrulamaları ve hata mesajlarını iyileştir.
- [ ] Mobil kulüp yönetim paneli yetersiz
  - Notlar: tüm kulüp alanları (name, short_name, category, description, main_color, logo_path, banner_path) editlenebilir; üye rol değiştirme modalı.
  - Plan: admin_settings_tab geliştirmeleri, rol diyalogu ve liste.
- [ ] Banner ve profil fotoğrafları kullanımı
  - Notlar: tüm kulüp kartlarında ve detaylarında public URL çözümü; fallback görseller.
- [ ] Top bar düzeni
  - Notlar: solda “UniHub”, ortada aktif sayfa başlığı (Keşfet/Etkinlikler/Kulüplerim/Profil); bildirim çanı sağda.
- [ ] Sponsor kartı metin okunabilirliği
  - Notlar: üst-alt koyu gradient overlay; metin beyaz; bannerden görsel olarak ayrışmalı.
- [ ] Profil sekmesindeki gereksiz geri tuşu kaldır
  - Notlar: profil ekranı appBar/üst bar sadeleştirme.

## Tamamlanan (Onaylanırsa tiklenecek)
- [ ] EventModel + SpeakerModel eklendi; Supabase join’leri güncellendi.
- [ ] Mobil EventCard konuşmacı desteği.
- [ ] Mobil kulüp ayarlarında logo/banner yükleme ve renk düzenleme.
- [ ] Modern profil ekranı tek sayfa, bilgi kartları.

## Notlar
- auth.users join kullanılmaz; e‑posta profiles tablosundan okunur.
- Storage: `clubs` bucket; klasörler `logos/` ve `banners/`.

## Güncelleme Akışı
- Yeni istek → “Yapılacaklar”a ekle.
- Bitti → “Tamamlanan”a taşı ve tikle.
- Detay kararlar → “Notlar”a kısa madde olarak ekle.
