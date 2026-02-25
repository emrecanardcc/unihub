import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase;
  
  NotificationService() : _supabase = Supabase.instance.client;

  // Bildirimleri stream olarak dinle
  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // Okunmamış bildirim sayısını al
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;
      
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .count();
      
      return response.count;
    } catch (e) {
      debugPrint('Bildirim sayısı alınamadı: $e');
      return 0;
    }
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Bildirim okundu olarak işaretlenemedi: $e');
    }
  }

  // Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead() async {
    try {
      await _supabase.rpc('mark_all_notifications_as_read', params: {
        'user_uuid': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      debugPrint('Tüm bildirimler okundu olarak işaretlenemedi: $e');
    }
  }

  // Manuel bildirim oluştur (isteğe bağlı)
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
    String? relatedId,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'related_id': relatedId,
      });
    } catch (e) {
      debugPrint('Bildirim oluşturulamadı: $e');
    }
  }

  // Bildirim sil
  Future<void> deleteNotification(String notificationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Bildirim silinemedi: $e');
    }
  }

  // Tüm bildirimleri temizle
  Future<void> clearAllNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Bildirimler temizlenemedi: $e');
    }
  }
}
