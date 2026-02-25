-- Bildirim sistemi tabloları

-- notifications tablosu
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'general', -- 'event', 'club', 'system', 'general'
    related_id UUID, -- İlgili kaydın ID'si (örn: etkinlik ID, kulüp ID)
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE
);

-- Index'ler
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);

-- RLS Politikaları
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Kullanıcılar sadece kendi bildirimlerini görebilir
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

-- Kullanıcılar kendi bildirimlerini güncelleyebilir (okundu olarak işaretleme)
CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Fonksiyon: Etkinlik oluşturulduğunda üyelere bildirim gönder
CREATE OR REPLACE FUNCTION notify_club_members_on_event()
RETURNS TRIGGER AS $$
BEGIN
    -- Kulüp üyelerine bildirim gönder
    INSERT INTO public.notifications (user_id, title, message, type, related_id)
    SELECT 
        cm.user_id,
        'Yeni Etkinlik: ' || NEW.title,
        'Kulübünüzde "' || NEW.title || '" adlı yeni bir etkinlik oluşturuldu. Detayları görmek için tıklayın.',
        'event',
        NEW.id
    FROM public.club_members cm
    WHERE cm.club_id = NEW.club_id 
    AND cm.status = 'active'
    AND cm.user_id != auth.uid(); -- Etkinliği oluşturan kişiye bildirim gönderme

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Etkinlik oluşturulduğunda bildirim gönder
CREATE TRIGGER trigger_notify_on_event_creation
    AFTER INSERT ON public.events
    FOR EACH ROW
    EXECUTE FUNCTION notify_club_members_on_event();

-- Fonksiyon: Okundu tarihini güncelle
CREATE OR REPLACE FUNCTION mark_notification_as_read()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_read = TRUE AND OLD.is_read = FALSE THEN
        NEW.read_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Bildirim okunduğunda read_at tarihini güncelle
CREATE TRIGGER trigger_mark_notification_read
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION mark_notification_as_read();

-- Fonksiyon: Okunmamış bildirim sayısını al
CREATE OR REPLACE FUNCTION get_unread_notification_count(user_uuid UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM public.notifications WHERE user_id = user_uuid AND is_read = FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonksiyon: Tüm bildirimleri okundu olarak işaretle
CREATE OR REPLACE FUNCTION mark_all_notifications_as_read(user_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.notifications 
    SET is_read = TRUE 
    WHERE user_id = user_uuid AND is_read = FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;